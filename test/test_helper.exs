ExUnit.configure(formatters: [ExUnit.CLIFormatter])

{:ok, _} = Application.ensure_all_started(:ex_machina)

DomainLogic.Repo.start_link()
Ecto.Adapters.SQL.Sandbox.mode(DomainLogic.Repo, :manual)

ExUnit.start()
