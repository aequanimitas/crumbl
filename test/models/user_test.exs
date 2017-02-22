defmodule Crumbl.UserTest do
  use Crumbl.ModelCase, async: true

  alias Crumbl.User

  @valid_attrs %{username: "hta", name: "hector", password: "secretly"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "changeset doesn't accept long usernames" do
    attrs = Map.put @valid_attrs, :username, String.duplicate("a", 101)
    assert {:username, {"should be at most %{count} character(s)", [count: 20]}} in errors_on(%User{}, attrs)
  end
end
