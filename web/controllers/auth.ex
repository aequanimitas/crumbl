defmodule Crumbl.Auth do
  import Plug.Conn
  import Phoenix.Controller  # for put_flash and redirect
  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]

  alias Crumbl.Router.Helpers   # for page_path helper
  
  def init(opts) do
    # pass the MODULE.Repo to call, receives :repo from declaration in controller
    Keyword.fetch! opts, :repo
  end

  def call(conn, repo) do
    user_id = get_session(conn, :user_id)
    user = user_id && repo.get(Crumbl.User, user_id)
    assign(conn, :current_user, user)
  end

  def login(conn, user) do
    conn
    # assign to conn struct key current_user that points to user
    |> assign(:current_user, user)
    |> put_session(:user_id, user.id)
    # send session back to client with a different identifier
    # protection from session fixation
    |> configure_session(renew: true)
  end

  def logout(conn) do
    configure_session(conn, drop: true)
  end

  def login_by_uname_pass(conn, username, pass, opts) do
    # the fetch without bang returns a status tuple
    # this returns an actual module
    repo = Keyword.fetch!(opts, :repo)
    user = repo.get_by(Crumbl.User, username: username)

    cond do
      user && checkpw(pass, user.password_hash) -> # found w/ proper creds, checkpw in Bcrypt, no reverse
        {:ok, login(conn, user)}
      user -> # if a user is found but password doesn't match
        {:error, :unauthorized, conn}
      true -> # otherwise return not found
        dummy_checkpw() # simulate a password check with variable timing
        {:error, :not_found, conn}
    end
  end

  def authenticate_user(conn, _opts) do
    if conn.assigns.current_user do
      # return conn unchanged
      conn
    else
      conn
      # else show flash message
      |> put_flash(:error, "You need to be logged for that operation")
      # redirect to app root
      |> redirect(to: Helpers.page_path(conn, :index))
      # stop any downstream transformations from happening
      # and just return the current connection
      |> halt()
    end
  end
end
