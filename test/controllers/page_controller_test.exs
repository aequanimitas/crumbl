defmodule Crumbl.PageControllerTest do
  use Crumbl.ConnCase

  setup do
    user = insert_user(username: "hec")
    conn = assign(build_conn(), :current_user, user)
    {:ok, conn: conn, user: user}
  end

  test "ensure :current_user is in conn", %{conn: conn} do
    assert conn.assigns[:current_user]
    conn = get conn, "/"
    assert conn.assigns[:current_user]
  end

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Welcome to Crumbl!"
  end
end
