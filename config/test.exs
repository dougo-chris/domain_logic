use Mix.Config

# Configure your database
config :linklab_domain_logic, DomainLogic.Ecto.Test.Repo,
  load_from_system_env: false,
  username: "root",
  password: "",
  database: "domain_logic_test",
  hostname: "localhost",
  port: 3306,
  pool: Ecto.Adapters.SQL.Sandbox
