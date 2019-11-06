use Mix.Config

config :logger, :console, level: :error

config :domain_logic, ecto_repos: [DomainLogic.Repo]

# Configure your database
config :domain_logic, DomainLogic.Repo,
  load_from_system_env: false,
  username: "root",
  password: "",
  database: "domain_logic_test",
  hostname: "localhost",
  port: 3306,
  pool: Ecto.Adapters.SQL.Sandbox
