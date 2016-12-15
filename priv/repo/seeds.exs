# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Crumbl.Repo.insert!(%Crumbl.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias Crumbl.Repo
alias Crumbl.Category

for category <- ~w(Action Drama Romance Comedy Sci-Fi) do
  # quick solution, enough for dev env
  Repo.get_by(Category, name: category) || Repo.insert!(%Category{name: category})
end
