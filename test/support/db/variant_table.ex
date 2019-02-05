defmodule Linklab.DomainLogic.Test.Db.VariantTable do
  @moduledoc false

  use Ecto.Schema

  schema "dl_variants" do
    field :code, :string

    belongs_to :product, Linklab.DomainLogic.Test.Db.ProductTable, foreign_key: :product_id

    timestamps()
  end
end