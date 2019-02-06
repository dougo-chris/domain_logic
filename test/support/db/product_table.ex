defmodule Linklab.DomainLogic.Db.ProductTable do
  @moduledoc false

  use Ecto.Schema

  schema "dl_products" do
    field :name, :string
    field :price, :integer
    field :available, :boolean

    belongs_to :category, Linklab.DomainLogic.Db.CategoryTable, foreign_key: :category_id
    has_many :variants, Linklab.DomainLogic.Db.VariantTable, foreign_key: :product_id

    timestamps()
  end
end