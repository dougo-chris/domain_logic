defmodule DomainLogic.Test.Repo do
  use Ecto.Repo, otp_app: :domain_logic, adapter: Ecto.Adapters.MyXQL
  use Scrivener, page_size: 10, max_page_size: 100
end
