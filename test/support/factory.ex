defmodule Linklab.DomainLogic.Test.Factory do
  @moduledoc false

  # with Ecto
  use ExMachina.Ecto, repo: Linklab.DomainLogic.Test.Repo

  def category_factory do
    %Linklab.DomainLogic.Test.Db.CategoryTable{
      title: "Elixir"
    }
  end

  def product_factory do
    name = sequence(:name, &"Use ExMachina! (Part #{&1})")
    %Linklab.DomainLogic.Test.Db.ProductTable{
      name: name,
      price: 100,
      available: false,
      category: build(:category),
    }
  end

  def variant_factory do
    %Linklab.DomainLogic.Test.Db.VariantTable{
      code: "VAR_1",
      product: build(:product),
    }
  end
end