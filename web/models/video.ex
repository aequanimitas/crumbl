defmodule Crumbl.Video do
  use Crumbl.Web, :model

  # {field, type, option}
  @primary_key {:id, Crumbl.Permalink, autogenerate: true}
  schema "videos" do
    field :url, :string
    field :title, :string
    field :description, :string
    field :slug, :string
    belongs_to :user, Crumbl.User
    belongs_to :category, Crumbl.Category

    timestamps()
  end

  @required_fields [:url, :title, :description]
  @optional_fields ~w(category_id)

  @doc """
  Builds a changeset based on the `struct` and `params`.

  - Can validate data, but delegate data integrity validations to the DB
  - the beauty of changes that needs to be made described by the flow, its like story telling
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields, @optional_fields)
    |> validate_required(@required_fields)
    |> slugify_title()
    |> assoc_constraint(:category)
  end

  defp slugify_title(changeset) do
    if title = get_change(changeset, :title) do
      put_change(changeset, :slug, slugify(title))
    else
      changeset
    end
  end

  defp slugify(title) do
    title
    |> String.downcase()
    |> String.replace(~r/[^\w-]+/u, "-")
  end

  # Protocols: A way for Elixir to perform Polymorphism
  # Phoenix.Param default is to extract the id of the struct, if it has one
  defimpl Phoenix.Param, for: Crumbl.Video do
    def to_param(%{slug: slug, id: id}) do
      "#{id}-#{slug}"
    end
  end
end
