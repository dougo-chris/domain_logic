defmodule DomainLogic.Db.VariantTable do
  @moduledoc false

  use Ecto.Schema

  schema "dl_variants" do
    field(:code, :string)

    belongs_to(:product, DomainLogic.Db.ProductTable, foreign_key: :product_id)

    timestamps()
  end
end
