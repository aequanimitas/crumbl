defmodule Crumbl.SessionController do
  use Crumbl.Web, :controller

  def new(conn, _) do
    render conn, "new.html"
  end

  def delete(conn, _) do
    conn
    |> Crumbl.Auth.logout()  # call logout plug
    |> redirect(to: page_path(conn, :index))
  end

  def create(conn, %{"session" => %{"username" => user, "password" => pass }}) do
    case Crumbl.Auth.login_by_uname_pass(conn, user, pass, repo: Repo) do
      {:ok, conn} ->
        conn
        |> put_flash(:info, "Welcome back")
        |> redirect(to: page_path(conn, :index))
      {:error, _reason, conn} ->
        conn
        |> put_flash(:error, "Invalid username / password")
        |> render("new.html")
    end
  end
end
