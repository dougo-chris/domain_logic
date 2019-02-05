ExUnit.configure(formatters: [ExUnit.CLIFormatter])

{:ok, _} = Application.ensure_all_started(:ex_machina)

Linklab.DomainLogic.Test.Repo.start_link()
Ecto.Adapters.SQL.Sandbox.mode(Linklab.DomainLogic.Test.Repo, :manual)

ExUnit.start()
