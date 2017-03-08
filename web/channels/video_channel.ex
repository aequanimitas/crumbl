defmodule Crumbl.VideoChannel do
  use Crumbl.Web, :channel

  # string pattern-matching via concat(??)
  def join("videos:" <> video_id, _params, socket) do
    # send via erlang
    # authorize a "join" attempt, {:error, socket} to done
    # just like plug conn struct, first argument is connection details struct
    video_id = String.to_integer(video_id)
    video = Repo.get!(Crumbl.Video, video_id)
    annotations = Repo.all(
      from a in assoc(video, :annotations),
        order_by: [asc: a.at, asc: a.id],
        limit: 200,
        preload: [:user]
    )

    resp = %{annotations: Phoenix.View.render_many(annotations, Crumbl.AnnotationView, "annotation.json")}
    {:ok, resp, assign(socket, :video_id, video_id)}
  end

  @ doc """
  Catch-all for ```handle_in```, check if user is registered.
  ```socket.assigns.user_id``` is created at auth plug, so make sure that you match
  the key created there
  """
  def handle_in(event, params, socket) do
    user = Repo.get(Crumbl.User, socket.assigns.user_id)
    handle_in(event, params, user, socket)
  end

  def handle_in("new_annotation", params, user, socket) do
    # send to ALL users subscribed to the TOPIC
    # be careful with what you send
    changeset = 
      user
      |> build_assoc(:annotations, video_id: socket.assigns.video_id)
      |> Crumbl.Annotation.changeset(params)

    case Repo.insert(changeset) do
      {:ok, annotation} ->
        broadcast! socket, "new_annotation", %{
          id: annotation.id,
          user: Crumbl.UserView.render("user.json", %{user: user}),
          body: annotation.body,
          at: annotation.at
        }
        {:reply, :ok, socket}
      {:error, changeset} ->
        IO.puts inspect changeset
        {:reply, {:error, %{errors: changeset}}, socket}
    end
  end

  # receive here
  def handle_info(:ping, socket) do
    count = socket.assigns[:count] || 1
    push socket, "ping", %{count: count}
    {:noreply, assign(socket, :count, count + 1)}
  end
end
