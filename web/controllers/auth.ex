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
    cond do
      # refactor so that code can be more testable

      # - conn is from Plug
      # - assigns is part of Connection Field in conn
      # - returns nil if, in this case :current_user, is not set
      # return conn if :current_user is set in shared user data map

      user = conn.assigns[:current_user] -> put_current_user(conn, user)

      # This clause has 2 conditions
      # - if in session there is already a user
      # - and if db lookup there is really a user with the same credentials
      # return conn after verifying the user
      # The assign here is from Plug.Conn, which assigns a value to a key in the connection
      user = user_id && repo.get(Crumbl.User, user_id) -> put_current_user(conn, user)

      # Finally, nilify the :current_user if none of the above passes
      true -> assign(conn, :current_user, nil)
    end

    # Initial code, refactored to the one above for testing
    # user = user_id && repo.get(Crumbl.User, user_id)
    # assign(conn, :current_user, user)
  end

  def login(conn, user) do
    conn
    |> put_current_user(user)
    |> put_session(:user_id, user.id)
    # send session back to client with a different identifier
    # protection from session fixation
    |> configure_session(renew: true)
  end

  defp put_current_user(conn, user) do
    token = Phoenix.Token.sign(conn, "user socket", user.id)
    conn
    |> assign(:current_user, user)
    |> assign(:user_token, token)
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
