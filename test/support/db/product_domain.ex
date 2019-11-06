defmodule DomainLogic.Db.ProductDomain do
  @moduledoc false

  use DomainLogic,
    repo: DomainLogic.Repo,
    table: DomainLogic.Db.ProductTable

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
