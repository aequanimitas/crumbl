defmodule Crumbl.Repo do
  #use Ecto.Repo, otp_app: :crumbl

  @moduledoc """
  in module repository
  """

  def all(Crumbl.User) do
    [
      %Crumbl.User{id: "1", name: "hec", username: "josevalim", password: "elixir"},
      %Crumbl.User{id: "2", name: "maria", username: "mya", password: "school"},
      %Crumbl.User{id: "3", name: "ey", username: "ey", password: "tahi"},
    ]
  end

  def all(_module), do: []

  def get(module, id) do
    Enum.find all(module), fn map -> map.id == id end
  end

  def get_by(module, params) do
    Enum.find all(module), fn map ->
      Enum.all?(params, fn {k, v} -> Map.get(map, k) == v end)
    end
  end
end
