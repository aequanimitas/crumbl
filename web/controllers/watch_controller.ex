defmodule Crumbl.WatchController do
  use Crumbl.Web, :controller

  alias Crumbl.Video

  def show(conn, %{"id" => id}) do
    video = Repo.get!(Video, id)
    render conn, "show.html", video: video
  end
end
