defmodule Crumbl.UserTest do
  use Crumbl.ModelCase, async: true

  alias Crumbl.User

  @valid_attrs %{username: "hta", name: "hector"}
  
  test "converts unique_constraint on username on error" do
    insert_user(username: "hector")
    attrs = Map.put(@valid_attrs, :username, "hector")
    changeset = User.changeset(%User{}, attrs)

    assert {:error, changeset} = Repo.insert(changeset)
    assert {:username, "has already been taken"} in changeset.errors
  end
end
