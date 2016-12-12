defmodule Crumbl.UserView do
  use Crumbl.Web, :view
  alias Crumbl.User

  def first_name(%User{name: name}) do
    name
    |> String.split(" ")
    |> Enum.at(0)
  end
end
