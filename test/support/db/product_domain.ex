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
    filter(:category_title, :string, association: :category, source: :title)
    filter(:category_code, :integer, association: :category, source: :code)
  end

  register_sort do
    sort(:id)
    sort(:name)
    sort(:price)
    sort(:category_title, association: :category, source: :title)
    sort(:category_code, association: :category, source: :code)
  end
end
