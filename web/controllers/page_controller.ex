defmodule Crumbl.PageController do
  use Crumbl.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
