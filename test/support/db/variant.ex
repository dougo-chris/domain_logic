defmodule DomainLogic.Ecto.Variant do
  @moduledoc false

  use Ecto.Schema

  schema "dl_variants" do
    field :name, :string
    field :price, :float
    field :length, :string
    field :width, :string
    field :height, :string

    belongs_to :product, DomainLogic.Ecto.Product

    timestamps()
  end
end