defmodule Crumbl.PageController do
  use Crumbl.Web, :controller

  def index(conn, _params) do
    user_id = get_session(conn, :user_id)
    render conn, "index.html"
  end
end
