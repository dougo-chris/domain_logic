ExUnit.configure(formatters: [ExUnit.CLIFormatter])

{:ok, _} = Application.ensure_all_started(:ex_machina)

DomainLogic.Test.Repo.start_link()
Ecto.Adapters.SQL.Sandbox.mode(DomainLogic.Test.Repo, :manual)

ExUnit.start()
