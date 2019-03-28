defmodule Linklab.DomainLogic.Db.ProductDomain do
  @moduledoc false

  use Linklab.DomainLogic,
    repo: Linklab.DomainLogic.Repo,
    table: Linklab.DomainLogic.Db.ProductTable

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
