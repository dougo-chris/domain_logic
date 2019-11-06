use Mix.Config

config :logger, :console, level: :error

config :domain_logic, ecto_repos: [DomainLogic.Test.Repo]

# Configure your database
config :domain_logic, DomainLogic.Test.Repo,
  username: "root",
  password: "",
  database: "domain_logic_test",
  hostname: "localhost",
  port: 3306,
  pool: Ecto.Adapters.SQL.Sandbox
