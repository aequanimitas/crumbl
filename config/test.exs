use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :crumbl, Crumbl.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :crumbl, Crumbl.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "crumbl_dev",
  password: "crumbl_dev",
  database: "crumbl_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
