defmodule VideoControllerTest do
  use Crumbl.ConnCase

  test "routes that need authentication", %{conn: conn} do
    Enum.each([
      get(conn, video_path(conn, :new)),
      get(conn, video_path(conn, :index)),
      get(conn, video_path(conn, :show, "123890789")),
      get(conn, video_path(conn, :edit, "123890789")),
      put(conn, video_path(conn, :update, "123890789", %{})),
      post(conn, video_path(conn, :create, %{})),
      delete(conn, video_path(conn, :delete, "123890789")),
    ], fn(conn) -> 
      assert html_response(conn, 302)
      assert conn.halted
    end)
  end
end
