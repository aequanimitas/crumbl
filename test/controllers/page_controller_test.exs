defmodule Crumbl.PageControllerTest do
  use Crumbl.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Welcome to Crumbl!"
  end
end
