defmodule DomainLogic.Test.Db.ProductDomain do
  @moduledoc false

  use DomainLogic.Domain,
    repo: DomainLogic.Test.Repo,
    table: DomainLogic.Test.Db.ProductTable

  register_filter do
    filter(:id, :integer)
    filter(:name, :string)
    filter(:price, :integer)
    filter(:available, :boolean)
  end

  register_sort do
    sort(:id)
    sort(:name)
    sort(:price)
  end
end
