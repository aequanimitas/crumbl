defmodule Crumbl.User do
  use Crumbl.Web, :model

  schema "users" do
    field :name, :string
    field :username, :string
    # intermediate field before hashing
    field :password, :string, virtual: true
    field :password_hash, :string
    timestamps
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, ~w(name username), [])
    |> validate_length(:username, min: 1, max: 20)
    |> unique_constraint(:username)
  end
end
