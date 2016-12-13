defmodule Crumbl.Auth do
  import Plug.Conn

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
    |> assign(:current_user, user)
    |> put_session(:user_id, user.id)
    # send session back to client with a different identifier
    # protection from session fixation
    |> configure_session(renew: true)
  end
end
