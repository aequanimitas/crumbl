defmodule Crumbl.PageController do
  use Crumbl.Web, :controller

  def index(conn, _params) do
    _ = get_session(conn, :user_id)
    render conn, "index.html"
  end
end
