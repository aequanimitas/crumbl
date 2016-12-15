defmodule Crumbl.VideoController do
  use Crumbl.Web, :controller

  # alias models
  alias Crumbl.Video
  alias Crumbl.Category

  plug :load_categories when action in [:new, :edit, :update, :create]

  @doc """
    Plug that dispatches to proper action at end of controller pipeline
    This applies to ALL actions below
  """
  def action(conn, _) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.current_user])
  end

  @doc """
     Function plug that loads categories, to be used in select tags
  """
  defp load_categories(conn, _) do
    # build query, query is a queryable, can be passed as argument to Repo
    query = Category |> Category.alphabetical |> Category.names_and_ids
    categories = Repo.all query
    # set as conn key
    assign(conn, :categories, categories)
  end

  def index(conn, _params, user) do
    videos = Repo.all(user_videos(user))
    render(conn, "index.html", videos: videos)
  end

  # user argument was added when the action :plug was overriden
  def new(conn, _params, user) do
    changeset =
      # commented out in favor of using the action :plug
      # avoids 
      # conn.assigns.current_user
      user
      |> build_assoc(:videos)
      |> Video.changeset()

    render(conn, "new.html", changeset: changeset)
  end

  # allow user to only edit and update their videos
  # also used to catch the conn struct processed by the action plug
  def user_videos(user) do
    assoc(user, :videos)
  end

  # user argument was added when the action :plug was overriden
  def create(conn, %{"video" => video_params}, user) do
    # changeset = Video.changeset(%Video{}, video_params)
    changeset = 
      user
      |> build_assoc(:videos)
      |> Video.changeset(video_params)

    case Repo.insert(changeset) do
      {:ok, _video} ->
        # No idea why "user" was here in the first place, can't remember
        # user
        conn
        |> put_flash(:info, "Video created successfully.")
        |> redirect(to: video_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}, user) do
    video = Repo.get!(user_videos(user), id)
    render(conn, "show.html", video: video)
  end

  # since :plug action was overridden
  # every action now on this controller expects 3 arguments
  # with the third being the current_user
  def edit(conn, %{"id" => id}, current_user) do
    video = Repo.get!(user_videos(current_user), id)
    changeset = Video.changeset(video)
    render(conn, "edit.html", video: video, changeset: changeset)
  end

  # since :plug action was overridden
  # every action now on this controller expects 3 arguments
  # with the third being the current_user
  def update(conn, %{"id" => id, "video" => video_params}, current_user) do
    video = Repo.get!(user_videos(current_user), id)
    changeset = Video.changeset(video, video_params)

    case Repo.update(changeset) do
      {:ok, video} ->
        conn
        |> put_flash(:info, "Video updated successfully.")
        |> redirect(to: video_path(conn, :show, video))
      {:error, changeset} ->
        render(conn, "edit.html", video: video, changeset: changeset)
    end
  end

  # since :plug action was overridden
  # every action now on this controller expects 3 arguments
  # with the third being the current_user
  def delete(conn, %{"id" => id}, current_user) do
    video = Repo.get!(user_videos(current_user), id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(video)

    conn
    |> put_flash(:info, "Video deleted successfully.")
    |> redirect(to: video_path(conn, :index))
  end
end
