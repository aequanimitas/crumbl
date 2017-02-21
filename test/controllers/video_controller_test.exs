defmodule VideoControllerTest do
  use Crumbl.ConnCase

  alias Crumbl.Video

  # to be clear what an valid and invalid video data looks like, add some module attributes
  @valid_attrs %{url: "http://youtu.be", title: "vid", description: "a vid"}
  @invalid_attrs %{title: "invalid"}

  defp video_count(qry), do: Repo.one(from v in qry, select: count(v.id))

  # get ```conn``` and check tags, if it exists
  # this helps keep the code DRY
  setup %{conn: conn} = config do
    if username = config[:login_as] do
      user = insert_user(username: username)
      conn = assign(build_conn(), :current_user, user)
      {:ok, conn: conn, user: user}
    else
      :ok
    end
  end

  # not testing all attributes but the things that are likely to break
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

  # to test only tagged test, do:
  # ```mix test test/controllers --only login_as
  @tag login_as: "max"
  test "List all user's videos on index", %{conn: conn, user: user} do
    user_video = insert_video(user, title: "funny cats")
    other_video = insert_user(username: "hec") |> insert_video(title: "funny cats too")
    conn = get conn, video_path(conn, :index)
    assert html_response(conn, 200) =~ ~r/Listing videos/
    assert String.contains?(conn.resp_body, user_video.title)
    refute String.contains?(conn.resp_body, other_video.title)
  end

  # redirect
  test "creates video without credentials", %{conn: conn} do
    conn = post conn, video_path(conn, :create), video: @valid_attrs
    assert redirected_to(conn) == page_path(conn, :index)
  end

  # to test only tagged test, do:
  # ```mix test test/controllers --only login_as
  @tag login_as: "max"
  test "creates user video and redirects", %{conn: conn, user: user} do
    conn = post conn, video_path(conn, :create), video: @valid_attrs
    assert redirected_to(conn) == video_path(conn, :index)
    assert Repo.get_by!(Video, @valid_attrs).user_id == user.id
  end

  # to test only tagged test, do:
  # ```mix test test/controllers --only login_as
  # this test handles our concern on how the flow should happen
  @tag login_as: "max"
  test "does not create video when invalid", %{conn: conn} do
    count_before = video_count(Video)
    conn = post conn, video_path(conn, :create), video: @invalid_attrs
    assert html_response(conn, 200) =~ "check the errors"
    assert video_count(Video) == count_before
  end

  # throw 404 when logged-in user is not owner
  # will show 404 error on production
  @tag login_as: "max"
  test "authorizes actions against access by other users", %{conn: conn, user: owner} do
    video = insert_video(owner, @valid_attrs)
    non_owner = insert_user(username: "sneaky")
    conn = assign(conn, :current_user, non_owner)
    assert_error_sent :not_found, fn ->
      get(conn, video_path(conn, :show, video))
    end
    assert_error_sent :not_found, fn ->
      get(conn, video_path(conn, :edit, video))
    end
    assert_error_sent :not_found, fn ->
      get(conn, video_path(conn, :delete, video))
    end
    assert_error_sent :not_found, fn ->
      get(conn, video_path(conn, :update, video))
    end
  end
end
