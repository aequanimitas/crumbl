defmodule Crumbl.AuthTest do
  use Crumbl.ConnCase
  alias Crumbl.Auth

  # bypass route dispatch, give conn all the necesarry transformations such as sessions
  # and flash messages
  setup %{conn: conn} do
    conn =
      conn
      |> bypass_through(Crumbl.Router, :browser)
      |> get("/")
    {:ok, %{conn: conn}}
  end

  test "authenticate_user halts when no :current user exists", %{conn: conn} do
    conn = Auth.authenticate_user(conn, [])
    assert conn.halted()
  end

  test "authenticate_user proceeds when :current user exists", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, %Crumbl.User{})
      |> Auth.authenticate_user([])
    refute conn.halted()
  end

  test "login puts the :user_id in session", %{conn: conn} do
    login_conn = 
      conn
      |> Auth.login(%Crumbl.User{id: 123})
      |> send_resp(:ok, "")
    # make sure session key :user_id still exists by issuing a new request with the old
    # connection
    next_conn = get(login_conn, "/")
    assert get_session(next_conn, :user_id)
  end

  # make sure logged out users are logged out
  test "logout remove the :user_id in session", %{conn: conn} do
    user = insert_user()
    logout_conn = 
      conn
      |> put_session(:user_id, user.id)
      |> Auth.logout()
      |> send_resp(:ok, "")
    # make sure session key :user_id still exists by issuing a new request with the old
    # connection
    next_conn = get(logout_conn, "/")
    refute get_session(next_conn, :user_id)
  end

  test "Crumbl.Auth.call places user from session to assigns", %{conn: conn} do
    user = insert_user()
    conn =
      conn
      |> put_session(:user_id, user.id)
      |> Auth.call(Repo)
    assert conn.assigns.current_user.id == user.id
  end

  test "Crumbl.Auth.call sets :current_user to nil", %{conn: conn} do
    conn = Auth.call(conn, Repo)
    assert conn.assigns.current_user == nil
  end

  test "login with a valid username and password", %{conn: conn} do
    user = insert_user(username: "hta", password: "password")
    {:ok, conn} = Auth.login_by_uname_pass(conn, "hta", "password", repo: Repo)
    assert conn.assigns.current_user.id == user.id
  end

  test "login with a not found user", %{conn: conn} do
    assert {:error, :not_found, conn} ==
            Auth.login_by_uname_pass(conn, "hta", "password", repo: Repo)
  end

  test "login with a wrong password", %{conn: conn} do
    _ = insert_user(username: "hta", password: "password")
    assert {:error, :unauthorized, conn} == 
           Auth.login_by_uname_pass(conn, "hta", "passwordz", repo: Repo)
  end
end
