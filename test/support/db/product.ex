defmodule DomainLogic.Ecto.Product do
  @moduledoc false

  use Ecto.Schema

  schema "dl_products" do
    field :name, :string
    field :body, :string
    field :price, :float
    field :available, :boolean

    belongs_to :category, DomainLogic.Ecto.Category
    has_many :variants, DomainLogic.Ecto.Variant

    timestamps()
  end
end