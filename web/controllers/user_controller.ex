defmodule Crumbl.UserController do
  use Crumbl.Web, :controller

  def index(conn, _params) do
    users = Repo.all Crumbl.User
    render conn, "index.html", users: users
  end

  def show(conn, %{"id" => id}) do
    user = Repo.get Crumbl.User, id
    render conn, "show.html", user: user
  end
end
