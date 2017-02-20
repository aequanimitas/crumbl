defmodule VideoControllerTest do
  use Crumbl.ConnCase

  setup do
    user = insert_user(username: "max")
    conn = assign(build_conn(), :current_user, user)
    {:ok, conn: conn, user: user}
  end

  test "routes that need authentication", %{conn: conn, user: user} do
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

  test "List all user's videos on index", %{conn: conn, user: user} do
    user_video = insert_video(user, title: "funny cats")
    other_video = insert_user(username: "hec") |> insert_video(title: "funny cats too")
    conn = get conn, video_path(conn, :index)
    assert html_response(conn, 200) =~ ~r/Listing videos/
    assert String.contains?(conn.resp_body, user_video.title)
    refute String.contains?(conn.resp_body, other_video.title)
  end
end
