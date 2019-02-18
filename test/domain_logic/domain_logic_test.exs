defmodule Linklab.DomainLogic.DomainLogicTest do
  use Linklab.DomainLogic.DataCase

  alias Linklab.DomainLogic.Db.ProductDomain
  alias Linklab.DomainLogic.Db.ProductTable

  describe "#find" do
    test "it should be valid" do
      product = insert(:product)
      {:ok, record} = ProductDomain.find(ProductTable, {:id, product.id})
      assert record.id == product.id
    end

    test "it should be invalid" do
      {:error, reason} = ProductDomain.find(ProductTable, {:id, 1001})
      assert reason == "Not found"
    end
  end

  describe "#one" do
    test "it should be valid" do
      product = insert(:product)
      {:ok, record} = ProductDomain.one(ProductTable)
      assert record.id == product.id
    end

    test "it should be invalid when NO records" do
      {:error, result} = ProductDomain.one(ProductTable)
      assert result == "Not found"
    end

    test "it should raise an error if mutiple results" do
      insert(:product)
      insert(:product)

      assert_raise Ecto.MultipleResultsError, fn ->
        ProductDomain.one(ProductTable)
      end
    end
  end

  describe "#all" do
    test "it should be valid" do
      first = insert(:product)
      next = insert(:product)
      last = insert(:product)
      records = ProductDomain.all(ProductTable)

      ids =
        records
        |> Enum.map(fn record -> record.id end)
        |> Enum.sort_by(fn id -> id end)

      assert ids == [first.id, next.id, last.id]
    end

    test "it should be empty when NO records" do
      records = ProductDomain.all(ProductTable)
      assert records == []
    end
  end

  describe "#paginate" do
    test "it should return the first page" do
      first = insert(:product)
      next = insert(:product)
      _last = insert(:product)

      result =
        ProductTable
        |> ProductDomain.sort_by({:id, :asc})
        |> ProductDomain.paginate({1, 2})

      ids =
        result.entries
        |> Enum.map(fn record -> record.id end)
        |> Enum.sort_by(fn id -> id end)

      assert ids == [first.id, next.id]
      assert result.page_number == 1
      assert result.page_size == 2
      assert result.total_entries == 3
      assert result.total_pages == 2
    end

    test "it should be return more pages" do
      _first = insert(:product)
      next = insert(:product)
      _last = insert(:product)

      result =
        ProductTable
        |> ProductDomain.sort_by({:id, :asc})
        |> ProductDomain.paginate({2, 1})

      ids =
        result.entries
        |> Enum.map(fn record -> record.id end)
        |> Enum.sort_by(fn id -> id end)

      assert ids == [next.id]
      assert result.page_number == 2
      assert result.page_size == 1
      assert result.total_entries == 3
      assert result.total_pages == 3
    end

    test "it should return the first page when before the first" do
      first = insert(:product)
      _next = insert(:product)
      _last = insert(:product)

      result =
        ProductTable
        |> ProductDomain.sort_by({:id, :asc})
        |> ProductDomain.paginate({0, 1})

      ids =
        result.entries
        |> Enum.map(fn record -> record.id end)
        |> Enum.sort_by(fn id -> id end)

      assert ids == [first.id]
      assert result.page_number == 1
      assert result.page_size == 1
      assert result.total_entries == 3
      assert result.total_pages == 3
    end

    test "it should return the last page when past the end" do
      _first = insert(:product)
      _next = insert(:product)
      last = insert(:product)

      result =
        ProductTable
        |> ProductDomain.sort_by({:id, :asc})
        |> ProductDomain.paginate({100, 1})

      ids =
        result.entries
        |> Enum.map(fn record -> record.id end)
        |> Enum.sort_by(fn id -> id end)

      assert ids == [last.id]
      assert result.page_number == 3
      assert result.page_size == 1
      assert result.total_entries == 3
      assert result.total_pages == 3
    end
  end

  describe "#count" do
    test "it should be zero with no records" do
      assert ProductDomain.count(ProductTable) == 0
    end

    test "it should be the number of records" do
      insert(:product)
      insert(:product)
      insert(:product)
      assert ProductDomain.count(ProductTable) == 3
    end
  end

  describe "#filter_by" do
    test "fields" do
      test_filter_by_integer(ProductDomain, ProductTable, :product, :id)
      test_filter_by_string(ProductDomain, ProductTable, :product, :name)
      test_filter_by_integer(ProductDomain, ProductTable, :product, :price)
      test_filter_by_boolean(ProductDomain, ProductTable, :product, :available)
    end

    test "invalid field name" do
      assert_raise ArgumentError, ~r/Invalid field/, fn ->
        ProductDomain.filter_by(ProductTable, {:wrong, :eq, 1001})
      end
    end

    test "invalid field operation" do
      assert_raise ArgumentError, ~r/Invalid operation/, fn ->
        ProductDomain.filter_by(ProductTable, {:id, :invalid, 1001})
      end
    end

    test "invalid field value" do
      assert_raise ArgumentError, ~r/Invalid value/, fn ->
        ProductDomain.filter_by(ProductTable, {:id, :eq, ~r/bill/})
      end
    end
  end

  describe "#filter_validate" do
    test "clean valid filters" do
      filter =
        ProductDomain.filter_validate(
          [
            {:id, :eq, 1001},
            {"name", "eq", "BOB"}
          ]
        )

      assert filter == [{:id, :eq, 1001}, {:name, :eq, "BOB"}]
    end

    test "fail on first invalid field" do
      {:error, reason} =
        ProductDomain.filter_validate(
          [
            {:id, :eq, 1001},
            {"name", "eq", "BOB"},
            {:unknown, :eq, 2002},
            {"wrong", :eq, 2002}
          ]
        )

      assert reason == "Invalid filter : Invalid field : unknown"
    end
  end

  describe "#filter_clean" do
    test "clean valid filters" do
      filter =
        ProductDomain.filter_clean(
          [
            {:id, :eq, 1001},
            {"name", "eq", "BOB"}
          ]
        )

      assert filter == [{:id, :eq, 1001}, {:name, :eq, "BOB"}]
    end

    test "remove invalid filters" do
      filter =
        ProductDomain.filter_clean(
          [
            {:id, :eq, 1001},
            {"name", "eq", "BOB"},
            {:unknown, :eq, 2002},
            {"wrong", :eq, 2002}
          ]
        )

      assert filter == [{:id, :eq, 1001}, {:name, :eq, "BOB"}]
    end
  end

  describe "#sort_by" do
    test "fields" do
      test_sort_by_integer(ProductDomain, ProductTable, :product, :id)
      test_sort_by_string(ProductDomain, ProductTable, :product, :name)
      test_sort_by_integer(ProductDomain, ProductTable, :product, :price)
    end

    test "invalid field name" do
      assert_raise ArgumentError, ~r/Invalid field/, fn ->
        ProductDomain.sort_by(ProductTable, {:wrong, :asc})
      end
    end

    test "invalid field operation" do
      assert_raise ArgumentError, ~r/Invalid operation/, fn ->
        ProductDomain.sort_by(ProductTable, {:id, :invalid})
      end
    end
  end

  describe "#sort_validate" do
    test "clean valid sorts" do
      sort =
        ProductDomain.sort_validate(
          [
            {:id, :asc},
            {"name", "asc"},
          ]
        )

      assert sort == [{:id, :asc}, {:name, :asc}]
    end

    test "fail on first invalid field" do
      {:error, reason} =
        ProductDomain.sort_validate(
          [
            {:id, :asc},
            {"name", "asc"},
            {:unknown, :desc},
            {"wrong", :desc}
          ]
        )

      assert reason == "Invalid sort : Invalid field : unknown"
    end
  end

  describe "#sort_clean" do
    test "clean valid sorts" do
      sort =
        ProductDomain.sort_clean(
          [
            {:id, :asc},
            {"name", "asc"},
          ]
        )

      assert sort == [{:id, :asc}, {:name, :asc}]
    end

    test "remove invalid sorts" do
      sort =
        ProductDomain.sort_clean(
          [
            {:id, :asc},
            {"name", "asc"},
            {:unknown, :desc},
            {"wrong", :desc}
          ]
        )

      assert sort == [{:id, :asc}, {:name, :asc}]
    end
  end

  describe "#limit_by" do
    test "offset and limit" do
      insert(:product, price: 11)
      insert(:product, price: 22)
      insert(:product, price: 33)
      insert(:product, price: 44)
      insert(:product, price: 55)
      insert(:product, price: 66)

      results =
        ProductTable
        |> ProductDomain.limit_by({2, 3})
        |> ProductDomain.all()
        |> Enum.map(fn record -> record.price end)

      assert results == [33, 44, 55]
    end

    test "limit only" do
      insert(:product, price: 11)
      insert(:product, price: 22)
      insert(:product, price: 33)
      insert(:product, price: 44)
      insert(:product, price: 55)
      insert(:product, price: 66)

      results =
        ProductTable
        |> ProductDomain.limit_by(3)
        |> ProductDomain.all()
        |> Enum.map(fn result -> result.price end)

      assert results == [11, 22, 33]
    end
  end

  describe "#preload_with" do
    test "it should load the category" do
      category = insert(:category)
      product = insert(:product, category: category)

      {:ok, record} =
        ProductTable
        |> ProductDomain.preload_with(:category)
        |> ProductDomain.find({:id, product.id})

      assert record.category.id == category.id
    end

    test "it should load the variants" do
      product = insert(:product)
      first = insert(:variant, product: product)
      last = insert(:variant, product: product)

      {:ok, record} =
        ProductTable
        |> ProductDomain.preload_with(:variants)
        |> ProductDomain.find({:id, product.id})

      ids = Enum.map(record.variants, fn variant -> variant.id end)
      assert ids == [first.id, last.id]
    end
  end
end
