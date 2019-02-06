defmodule Linklab.DomainLogic.DomainLogicTest do
  use Linklab.DomainLogic.DataCase

  alias Linklab.DomainLogic.Db.ProductDomain
  alias Linklab.DomainLogic.Db.ProductTable

  describe "find" do
    test "it should be valid" do
      product = insert(:product)
      {:ok, %ProductTable{} = record} = ProductDomain.find(ProductTable, {:id, product.id})
      assert record.id == product.id
    end

    test "it should be invalid" do
      {:error, reason} = ProductDomain.find(ProductTable, {:id, 1001})
      assert reason == "Not found"
    end
  end

  describe "preload_with" do
    test "it should load the category" do
      category = insert(:category)
      product = insert(:product, category: category)
      {:ok, record} =
        ProductTable
        |> ProductDomain.preload_with(:category)
        |> ProductDomain.find({:id, product.id})

      assert record.category == category
    end

    test "it should load the variant" do
      product = insert(:product)
      variant = insert(:variant, product: product)
      {:ok, record} =
        ProductTable
        |> ProductDomain.preload_with(:variants)
        |> ProductDomain.find({:id, product.id})

      assert Enum.map(record.variants, fn variant -> variant.id end) == [variant.id]
    end
  end

  describe "#filter_by" do
    test "fields" do
      test_filter_by_integer(ProductDomain, ProductTable, :product, :id)
      test_filter_by_string(ProductDomain, ProductTable, :product, :name)
      test_filter_by_integer(ProductDomain, ProductTable, :product, :price)
      test_filter_by_boolean(ProductDomain, ProductTable, :product, :available)
    end
  end
end
