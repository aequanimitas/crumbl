defmodule Crumbl.VideoChannel do
  use Crumbl.Web, :channel

  # string pattern-matching via concat(??)
  def join("videos:" <> video_id, _params, socket) do
    # authorize a "join" attempt, {:error, socket} to done
    # just like plug conn struct, first argument is connection details struct
    {:ok, assign(socket, :video_id, String.to_integer(video_id))}
  end
end
