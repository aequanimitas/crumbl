defmodule Crumbl.VideoChannel do
  use Crumbl.Web, :channel

  # string pattern-matching via concat(??)
  def join("videos:" <> video_id, _params, socket) do
    # send via erlang
    :timer.send_interval(5_000, :ping)
    # authorize a "join" attempt, {:error, socket} to done
    # just like plug conn struct, first argument is connection details struct
    {:ok, assign(socket, :video_id, String.to_integer(video_id))}
  end

  def handle_in("new_annotation", params, socket) do
    # send to ALL users subscribed to the TOPIC
    # be careful with what you send
    broadcast! socket, "new_annotation", %{
      user: %{username: "anon"},
      body: params["body"],
      at: params["at"]
    }
  end

  # receive here
  def handle_info(:ping, socket) do
    count = socket.assigns[:count] || 1
    push socket, "ping", %{count: count}
    {:noreply, assign(socket, :count, count + 1)}
  end
end
