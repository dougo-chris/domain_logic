defmodule DomainLogic.Ecto.Test.Repo do
  use Ecto.Repo, otp_app: :linklab_domain_logic, adapter: Ecto.Adapters.MySQL
end
