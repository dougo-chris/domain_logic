defmodule DomainLogic.Domain.Factory do
  @moduledoc false

  # with Ecto
  use ExMachina.Ecto, repo: DomainLogic.Test.Repo

  def category_factory do
    %DomainLogic.Test.Db.CategoryTable{
      title: "Elixir",
      code: sequence(:code, &(&1))
    }
  end

  def product_factory do
    name = sequence(:name, &"Use ExMachina! (Part #{&1})")

    %DomainLogic.Test.Db.ProductTable{
      name: name,
      price: 100,
      available: false,
      category: build(:category)
    }
  end

  def variant_factory do
    %DomainLogic.Test.Db.VariantTable{
      code: "VAR_1",
      product: build(:product)
    }
  end
end
