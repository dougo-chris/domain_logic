ExUnit.configure(formatters: [ExUnit.CLIFormatter])

{:ok, _} = Application.ensure_all_started(:ex_machina)

Linklab.DomainLogic.Repo.start_link()
Ecto.Adapters.SQL.Sandbox.mode(Linklab.DomainLogic.Repo, :manual)

ExUnit.start()
