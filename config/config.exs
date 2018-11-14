use Mix.Config

config :logger, :console,
  level: :error


config :linklab_domain_logic, ecto_repos: [DomainLogic.Ecto.Test.Repo]

import_config "#{Mix.env()}.exs"
