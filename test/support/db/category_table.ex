defmodule DomainLogic.Db.CategoryTable do
  @moduledoc false

  use Ecto.Schema

  schema "dl_categories" do
    field(:title, :string)

    has_many(:products, DomainLogic.Db.ProductTable, foreign_key: :category_id)

    timestamps()
  end
end
