ExUnit.configure(formatters: [ExUnit.CLIFormatter])

{:ok, _} = Application.ensure_all_started(:ex_machina)

DomainLogic.Ecto.Test.Repo.start_link()
Ecto.Adapters.SQL.Sandbox.mode(DomainLogic.Ecto.Test.Repo, :manual)

ExUnit.start()
