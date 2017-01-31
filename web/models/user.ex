defmodule Crumbl.User do
  use Crumbl.Web, :model

  schema "users" do
    field :name, :string
    field :username, :string
    # intermediate field before hashing
    field :password, :string, virtual: true
    field :password_hash, :string
    has_many :videos, Crumbl.Video
    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, ~w(name username), [])
    |> validate_length(:username, min: 1, max: 20)
    |> unique_constraint(:username)
  end

  @doc """
    Changeset that manager password change
  """
  def registration_changeset(model, params) do
    model
    # pass to changeset first
    |> changeset(params)
    # convert to a changeset for password
    |> cast(params, ~w(password), [])
    |> validate_length(:password, min: 6, max: 100)
    |> put_pass_hash()
  end

  def put_pass_hash(changeset) do
    case changeset do
      # if the changeset is valid
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        # add change to changeset, field :password_hash, value from Comeonin
        put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))
      _ ->
        changeset
    end
  end
end
