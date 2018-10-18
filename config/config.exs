use Mix.Config

config :logger, :console,
  level: :error


config :domain_logic, ecto_repos: [DomainLogic.Ecto.Test.Repo]

import_config "#{Mix.env()}.exs"
