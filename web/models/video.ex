defmodule Crumbl.Video do
  use Crumbl.Web, :model

  schema "videos" do
    field :url, :string
    field :title, :string
    field :description, :string
    belongs_to :user, Crumbl.User
    belongs_to :category, Crumbl.Category

    timestamps()
  end

  @required_fields [:url, :title, :description]
  @optional_fields ~w(category_id)

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields, @optional_fields)
    |> validate_required(@required_fields)
    |> assoc_constraint(:category)
  end
end
