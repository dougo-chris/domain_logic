defmodule DomainLogic.Ecto.Category do
  @moduledoc false

  use Ecto.Schema

  schema "dl_categories" do
    field :name, :string

    has_many :products, DomainLogic.Ecto.Product

    timestamps()
  end
end