defmodule VideoControllerTest do
  use Crumbl.ConnCase

  test "routes that need authentication", %{conn: conn} do
    Enum.each([
      get(conn, video_path(conn, :new)),
      get(conn, video_path(conn, :edit, "123890789")),
      get(conn, video_path(conn, :delete, "123890789")),
    ], fn(conn) -> 
      assert html_response(conn, 302)
      assert conn.halted
    end)
  end
end
