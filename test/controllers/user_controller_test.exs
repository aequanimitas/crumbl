defmodule UserControllerTest do
  use Crumbl.ConnCase

  test "routes that need authentication", %{conn: conn} do
    Enum.each([
    ], fn(conn) -> 
      assert html_response(conn, 302)
      assert conn.halted
    end)
  end
end
