defmodule Linklab.DomainLogic.Test.Repo do
  use Ecto.Repo, otp_app: :linklab_domain_logic, adapter: Ecto.Adapters.MySQL
  use Scrivener, page_size: 10, max_page_size: 100
end
