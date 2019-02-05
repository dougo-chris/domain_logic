defmodule Linklab.DomainLogic.Test.Db.ProductTable do
  @moduledoc false

  use Ecto.Schema

  schema "dl_products" do
    field :name, :string
    field :price, :integer
    field :available, :boolean

    belongs_to :category, Linklab.DomainLogic.Test.Db.CategoryTable, foreign_key: :category_id
    has_many :variants, Linklab.DomainLogic.Test.Db.VariantTable, foreign_key: :product_id

    timestamps()
  end
end