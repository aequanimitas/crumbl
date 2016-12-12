# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :crumbl,
  ecto_repos: [Crumbl.Repo]

# Configures the endpoint
config :crumbl, Crumbl.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "E+6d3P8xUmlb/ujTmvrMeD5KYpFI+fG1ByWsO0CNKdTwHCa949wAGeMQ9sKdlzVq",
  render_errors: [view: Crumbl.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Crumbl.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
