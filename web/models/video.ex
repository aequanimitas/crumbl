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

  @required_fields ~w(url title description)
  @optional_fields ~w(category_id)

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:url, :title, :description])
    |> validate_required([:url, :title, :description])
  end
end
