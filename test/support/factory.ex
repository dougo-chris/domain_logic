defmodule DomainLogic.Ecto.Factory do
  @moduledoc false

  # with Ecto
  use ExMachina.Ecto, repo: DomainLogic.Ecto.Repo

  def category_factory do
    %DomainLogic.Ecto.Category{
      name: "Elixir"
    }
  end

  def product_factory do
    name = sequence(:name, &"Use ExMachina! (Part #{&1})")
    %DomainLogic.Ecto.Product{
      name: name,
      body: "body",
      category: build(:category),
    }
  end

  def variant_factory do
    %DomainLogic.Ecto.Variant{
      name: "Variant 1",
      product: build(:product),
    }
  end
end