defmodule Crumbl.VideoViewTest do
  use Crumbl.ConnCase, async: true
  import Phoenix.View

  alias Crumbl.Video
  alias Crumbl.VideoView

  # sometimes views are simple enough that intgeration tests are simple enough
  # there are also instances that you won't test the view directly but instead
  # the functions you create to move the logic away from the templates into code
  test "renders index.html", %{conn: conn} do
    videos = [
      %Video{url: "http://youtu.be", title: "vid", description: "first vid", id: 1},
      %Video{url: "http://youtu.be", title: "next vid", description: "second vid", id: 2}
    ]
    content = render_to_string(VideoView, "index.html", conn: conn, videos: videos)

    assert String.contains?(content, "Listing videos")
    for v <- videos do
      assert String.contains?(content, v.title)
      assert String.contains?(content, v.description)
    end
  end

  test "renders new.html", %{conn: conn} do
    changeset = Video.changeset(%Video{})
    categories = [{"cats", 123}]

    content = render_to_string(
      VideoView, "new.html", 
      conn: conn, changeset: changeset, categories: categories
    )

    assert String.contains?(content, "New video")
  end
end
