defmodule Crumbl.UserController do
  use Crumbl.Web, :controller
  # convert private function into a plug instead of repeating the wall of code
  # on actions we need to apply. the only thing needed is to satisfy the contract that
  # function plugs needs 2 arguments: conn and params
  plug :authenticate when action in [:index, :show]
  alias Crumbl.User

  def index(conn, _params) do
    # this case pattern-matching needs to be applied to other routes? should you
    # repeat these lines inside those?
    #case autheticate(conn) do
    #  %Plug.Conn{halted: true} = conn ->
    #    conn
    #  conn ->
    #    users = Repo.all User
    #    render conn, "index.html", users: users
    #end
    users = Repo.all User
    render conn, "index.html", users: users
  end

  def show(conn, %{"id" => id}) do
    user = Repo.get User, id
    render conn, "show.html", user: user
  end

  def new(conn, _params) do
    changeset = User.changeset %User{}
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.registration_changeset %User{}, user_params
    case Repo.insert(changeset) do
      {:ok, user} ->
        conn
        |> Crumbl.Auth.login(user)
        |> put_flash(:info, "#{user.name} account created")
        |> redirect(to: user_path(conn, :index))
      {:error, changeset} ->
        conn
        |> render("new.html", changeset: changeset)
    end
  end

  defp authenticate(conn, _opts) do
    if conn.assigns.current_user do
      # return conn unchanged
      conn
    else
      conn
      # else show flash message
      |> put_flash(:error, "You need to be logged for that operation")
      # redirect to app root
      |> redirect(to: page_path(conn, :index))
      # stop any downstream transformations from happening
      # and just return the current connection
      |> halt()
    end
  end
end
