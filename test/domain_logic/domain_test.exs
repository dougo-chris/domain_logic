defmodule DomainLogic.DomainTest do
  use DomainLogic.Domain.DataCase

  import Ecto.Query

  alias DomainLogic.Test.Db.ProductDomain
  alias DomainLogic.Test.Db.ProductTable

  describe "#find query" do
    test "it should be valid" do
      product = insert(:product)
      {:ok, record} = ProductDomain.find(ProductTable, product.id)
      assert record.id == product.id
    end

    test "it should be invalid" do
      {:error, reason} = ProductDomain.find(ProductTable, 1001)
      assert reason == "Not found"
    end

    test "it should be valid with field" do
      product = insert(:product)
      {:ok, record} = ProductDomain.find(ProductTable, {:id, product.id})
      assert record.id == product.id
    end

    test "it should be invalid with field" do
      {:error, reason} = ProductDomain.find(ProductTable, {:id, 1001})
      assert reason == "Not found"
    end
  end

  describe "#find table" do
    test "it should be valid" do
      product = insert(:product)
      {:ok, record} = ProductDomain.find(product.id)
      assert record.id == product.id
    end

    test "it should be invalid" do
      {:error, reason} = ProductDomain.find(1001)
      assert reason == "Not found"
    end

    test "it should be valid with field" do
      product = insert(:product)
      {:ok, record} = ProductDomain.find({:id, product.id})
      assert record.id == product.id
    end

    test "it should be invalid with field" do
      {:error, reason} = ProductDomain.find({:id, 1001})
      assert reason == "Not found"
    end
  end

  describe "#one query" do
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
        ProductDomain.one()
      end
    end
  end

  describe "#one table" do
    test "it should be valid" do
      product = insert(:product)
      {:ok, record} = ProductDomain.one()
      assert record.id == product.id
    end

    test "it should be invalid when NO records" do
      {:error, result} = ProductDomain.one()
      assert result == "Not found"
    end

    test "it should raise an error if mutiple results" do
      insert(:product)
      insert(:product)

      assert_raise Ecto.MultipleResultsError, fn ->
        ProductDomain.one()
      end
    end
  end

  describe "#all query" do
    test "it should be valid" do
      first = insert(:product)
      next = insert(:product)
      last = insert(:product)
      records = ProductDomain.all()

      ids =
        records
        |> Enum.map(fn record -> record.id end)
        |> Enum.sort_by(fn id -> id end)

      assert ids == [first.id, next.id, last.id]
    end

    test "it should be empty when NO records" do
      records = ProductDomain.all()
      assert records == []
    end
  end

  describe "#all table" do
    test "it should be valid" do
      first = insert(:product)
      next = insert(:product)
      last = insert(:product)
      records = ProductDomain.all()

      ids =
        records
        |> Enum.map(fn record -> record.id end)
        |> Enum.sort_by(fn id -> id end)

      assert ids == [first.id, next.id, last.id]
    end

    test "it should be empty when NO records" do
      records = ProductDomain.all()
      assert records == []
    end
  end

  describe "#paginate query" do
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

  describe "#paginate table" do
    test "it should return the first page" do
      first = insert(:product)
      next = insert(:product)
      _last = insert(:product)

      result = ProductDomain.paginate({1, 2})

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

      result = ProductDomain.paginate({2, 1})

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

      result = ProductDomain.paginate({0, 1})

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

      result = ProductDomain.paginate({100, 1})

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

  describe "#count query" do
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

  describe "#count table" do
    test "it should be zero with no records" do
      assert ProductDomain.count() == 0
    end

    test "it should be the number of records" do
      insert(:product)
      insert(:product)
      insert(:product)
      assert ProductDomain.count() == 3
    end

    test "it should count by any field" do
      insert(:product, name: "one")
      insert(:product, name: "one")
      insert(:product, name: "one")

      count =
        ProductTable
        |> select([p], p.name)
        |> distinct(true)
        |> ProductDomain.count(:name)

      assert count == 1
    end
  end

  describe "#filter_by" do
    test "fields" do
      validate_filter_fields(ProductDomain)
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

    test "eq" do
      insert(:product, name: "AVALUE")
      insert(:product, name: "VALUE")
      insert(:product, name: "VALUEZ")

      op = [{:name, :eq, "VALUE"}]

      results =
        ProductTable
        |> ProductDomain.filter_by(op)
        |> ProductDomain.all()
        |> Enum.map(fn result -> Map.get(result, :name) end)

      assert results == ["VALUE"]
    end

    test "eq and nil value" do
      insert(:product, name: "AVALUE")
      insert(:product, name: nil)
      insert(:product, name: "VALUEZ")

      op = [{:name, :eq, nil}]

      results =
        ProductTable
        |> ProductDomain.filter_by(op)
        |> ProductDomain.all()
        |> Enum.map(fn result -> Map.get(result, :name) end)

      assert results == [nil]
    end

    test "eq by association" do
      insert(:product, name: "1", category: insert(:category, title: "AVALUE"))
      insert(:product, name: "2", category: insert(:category, title: "VALUE"))
      insert(:product, name: "3", category: insert(:category, title: "VALUEZ"))

      op = [{:category_title, :eq, "VALUE"}]

      results =
        ProductTable
        |> ProductDomain.filter_by(op)
        |> ProductDomain.all()
        |> Enum.map(fn result -> Map.get(result, :name) end)

      assert results == ["2"]
    end

    test "eq and nil by association" do
      insert(:product, name: "1", category: insert(:category, title: "AVALUE"))
      insert(:product, name: "2", category: insert(:category, title: nil))
      insert(:product, name: "3", category: insert(:category, title: "VALUEZ"))

      op = [{:category_title, :eq, nil}]

      results =
        ProductTable
        |> ProductDomain.filter_by(op)
        |> ProductDomain.all()
        |> Enum.map(fn result -> Map.get(result, :name) end)

      assert results == ["2"]
    end

    test "ne" do
      insert(:product, name: "AVALUE")
      insert(:product, name: "VALUE")
      insert(:product, name: "VALUEZ")

      op = [{:name, :ne, "VALUE"}]

      results =
        ProductTable
        |> ProductDomain.filter_by(op)
        |> ProductDomain.all()
        |> Enum.map(fn result -> Map.get(result, :name) end)
        |> Enum.sort_by(fn result -> result end)

      assert results == ["AVALUE", "VALUEZ"]
    end

    test "ne and nil" do
      insert(:product, name: "AVALUE")
      insert(:product, name: nil)
      insert(:product, name: "VALUEZ")

      op = [{:name, :ne, nil}]

      results =
        ProductTable
        |> ProductDomain.filter_by(op)
        |> ProductDomain.all()
        |> Enum.map(fn result -> Map.get(result, :name) end)
        |> Enum.sort_by(fn result -> result end)

      assert results == ["AVALUE", "VALUEZ"]
    end

    test "ne by association" do
      insert(:product, name: "1", category: insert(:category, title: "AVALUE"))
      insert(:product, name: "2", category: insert(:category, title: "VALUE"))
      insert(:product, name: "3", category: insert(:category, title: "VALUEZ"))

      op = [{:category_title, :ne, "VALUE"}]

      results =
        ProductTable
        |> ProductDomain.filter_by(op)
        |> ProductDomain.all()
        |> Enum.map(fn result -> Map.get(result, :name) end)
        |> Enum.sort_by(fn result -> result end)

      assert results == ["1", "3"]
    end

    test "ne and nil by association" do
      insert(:product, name: "1", category: insert(:category, title: "AVALUE"))
      insert(:product, name: "2", category: insert(:category, title: nil))
      insert(:product, name: "3", category: insert(:category, title: "VALUEZ"))

      op = [{:category_title, :ne, nil}]

      results =
        ProductTable
        |> ProductDomain.filter_by(op)
        |> ProductDomain.all()
        |> Enum.map(fn result -> Map.get(result, :name) end)
        |> Enum.sort_by(fn result -> result end)

      assert results == ["1", "3"]
    end

    test "gt" do
      insert(:product, name: "AVALUE")
      insert(:product, name: "VALUE")
      insert(:product, name: "VALUEZ")

      op = [{:name, :gt, "VALUE"}]

      results =
        ProductTable
        |> ProductDomain.filter_by(op)
        |> ProductDomain.all()
        |> Enum.map(fn result -> Map.get(result, :name) end)

      assert results == ["VALUEZ"]
    end

    test "gt by association" do
      insert(:product, name: "1", category: insert(:category, title: "AVALUE"))
      insert(:product, name: "2", category: insert(:category, title: "VALUE"))
      insert(:product, name: "3", category: insert(:category, title: "VALUEZ"))

      op = [{:category_title, :gt, "VALUE"}]

      results =
        ProductTable
        |> ProductDomain.filter_by(op)
        |> ProductDomain.all()
        |> Enum.map(fn result -> Map.get(result, :name) end)

      assert results == ["3"]
    end

    test "ge" do
      insert(:product, name: "AVALUE")
      insert(:product, name: "VALUE")
      insert(:product, name: "VALUEZ")

      op = [{:name, :ge, "VALUE"}]

      results =
        ProductTable
        |> ProductDomain.filter_by(op)
        |> ProductDomain.all()
        |> Enum.map(fn result -> Map.get(result, :name) end)

      assert Enum.sort(results) == ["VALUE", "VALUEZ"]
    end

    test "ge by association" do
      insert(:product, name: "1", category: insert(:category, title: "AVALUE"))
      insert(:product, name: "2", category: insert(:category, title: "VALUE"))
      insert(:product, name: "3", category: insert(:category, title: "VALUEZ"))

      op = [{:category_title, :ge, "VALUE"}]

      results =
        ProductTable
        |> ProductDomain.filter_by(op)
        |> ProductDomain.all()
        |> Enum.map(fn result -> Map.get(result, :name) end)

      assert results == ["2", "3"]
    end

    test "lt" do
      insert(:product, name: "AVALUE")
      insert(:product, name: "VALUE")
      insert(:product, name: "VALUEZ")

      op = [{:name, :lt, "VALUE"}]

      results =
        ProductTable
        |> ProductDomain.filter_by(op)
        |> ProductDomain.all()
        |> Enum.map(fn result -> Map.get(result, :name) end)

      assert results == ["AVALUE"]
    end

    test "lt by association" do
      insert(:product, name: "1", category: insert(:category, title: "AVALUE"))
      insert(:product, name: "2", category: insert(:category, title: "VALUE"))
      insert(:product, name: "3", category: insert(:category, title: "VALUEZ"))

      op = [{:category_title, :lt, "VALUE"}]

      results =
        ProductTable
        |> ProductDomain.filter_by(op)
        |> ProductDomain.all()
        |> Enum.map(fn result -> Map.get(result, :name) end)

      assert results == ["1"]
    end

    test "le" do
      insert(:product, name: "AVALUE")
      insert(:product, name: "VALUE")
      insert(:product, name: "VALUEZ")

      op = [{:name, :le, "VALUE"}]

      results =
        ProductTable
        |> ProductDomain.filter_by(op)
        |> ProductDomain.all()
        |> Enum.map(fn result -> Map.get(result, :name) end)

      assert Enum.sort(results) == ["AVALUE", "VALUE"]
    end

    test "le by association" do
      insert(:product, name: "1", category: insert(:category, title: "AVALUE"))
      insert(:product, name: "2", category: insert(:category, title: "VALUE"))
      insert(:product, name: "3", category: insert(:category, title: "VALUEZ"))

      op = [{:category_title, :le, "VALUE"}]

      results =
        ProductTable
        |> ProductDomain.filter_by(op)
        |> ProductDomain.all()
        |> Enum.map(fn result -> Map.get(result, :name) end)

      assert results == ["1", "2"]
    end

    test "lk" do
      insert(:product, name: "NOT ME")
      insert(:product, name: "AVALUE")
      insert(:product, name: "VALUE")
      insert(:product, name: "VALUEZ")
      insert(:product, name: "OR ME")

      op = [{:name, :lk, "VALUE"}]

      results =
        ProductTable
        |> ProductDomain.filter_by(op)
        |> ProductDomain.all()
        |> Enum.map(fn result -> Map.get(result, :name) end)

      assert Enum.sort(results) == ["AVALUE", "VALUE", "VALUEZ"]
    end

    test "lk by association" do
      insert(:product, name: "1", category: insert(:category, title: "NOT ME"))
      insert(:product, name: "2", category: insert(:category, title: "AVALUE"))
      insert(:product, name: "3", category: insert(:category, title: "VALUE"))
      insert(:product, name: "4", category: insert(:category, title: "VALUEZ"))
      insert(:product, name: "5", category: insert(:category, title: "OR ME"))

      op = [{:category_title, :lk, "VALUE"}]

      results =
        ProductTable
        |> ProductDomain.filter_by(op)
        |> ProductDomain.all()
        |> Enum.map(fn result -> Map.get(result, :name) end)

      assert results == ["2", "3", "4"]
    end

    test "in" do
      insert(:product, name: "FIND ME")
      insert(:product, name: "VALUE")

      op = [{:name, :in, ["FIND ME", "AND ME"]}]

      results =
        ProductTable
        |> ProductDomain.filter_by(op)
        |> ProductDomain.all()
        |> Enum.map(fn result -> Map.get(result, :name) end)

      assert Enum.sort(results) == ["FIND ME"]
    end

    test "in by association" do
      insert(:product, name: "1", category: insert(:category, title: "FIND ME"))
      insert(:product, name: "2", category: insert(:category, title: "VALUE"))

      op = [{:category_title, :in, ["FIND ME", "AND ME"]}]

      results =
        ProductTable
        |> ProductDomain.filter_by(op)
        |> ProductDomain.all()
        |> Enum.map(fn result -> Map.get(result, :name) end)

      assert Enum.sort(results) == ["1"]
    end
  end

  describe "#filter_validate" do
    test "clean valid filters" do
      {:ok, filter} =
        ProductDomain.filter_validate([
          {:id, :eq, 1001},
          {"name", "eq", "BOB"}
        ])

      assert filter == [{:id, :eq, 1001}, {"name", "eq", "BOB"}]
    end

    test "fail on first invalid field" do
      {:error, reason} =
        ProductDomain.filter_validate([
          {:id, :eq, 1001},
          {"name", "eq", "BOB"},
          {:unknown, :eq, 2002},
          {"wrong", :eq, 2002}
        ])

      assert reason == "Invalid filter : Invalid field : unknown"
    end

    test "fail on invalid item" do
      {:error, reason} =
        ProductDomain.filter_validate([
          {:id, :eq, 1001},
          {"name", "eq", "BOB"},
          "WRONG"
        ])

      assert reason == "Invalid filter : Invalid filter format"
    end
  end

  describe "#filter_clean" do
    test "clean valid filters" do
      filter =
        ProductDomain.filter_clean([
          {:id, :eq, 1001},
          {"name", "eq", "BOB"}
        ])

      assert filter == [{:id, :eq, 1001}, {"name", "eq", "BOB"}]
    end

    test "remove invalid filters" do
      filter =
        ProductDomain.filter_clean([
          {:id, :eq, 1001},
          {"name", "eq", "BOB"},
          {:unknown, :eq, 2002},
          {"wrong", :eq, 2002},
          "WRONG"
        ])

      assert filter == [{:id, :eq, 1001}, {"name", "eq", "BOB"}]
    end
  end

  describe "#sort_by" do
    test "fields" do
      validate_sort_fields(ProductDomain)
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

    test "asc" do
      insert(:product, name: "AAA")
      insert(:product, name: "DDD")
      insert(:product, name: "BBB")
      insert(:product, name: "CCC")

      op = [{:name, :asc}]

      results =
        ProductTable
        |> ProductDomain.sort_by(op)
        |> ProductDomain.repo().all()
        |> Enum.map(fn result -> Map.get(result, :name) end)

      assert results == ["AAA", "BBB", "CCC", "DDD"]
    end

    test "asc by association" do
      insert(:product, name: "1", category: insert(:category, title: "AAA"))
      insert(:product, name: "2", category: insert(:category, title: "DDD"))
      insert(:product, name: "3", category: insert(:category, title: "BBB"))
      insert(:product, name: "4", category: insert(:category, title: "CCC"))

      op = [{:category_title, :asc}]

      results =
        ProductTable
        |> ProductDomain.sort_by(op)
        |> ProductDomain.repo().all()
        |> Enum.map(fn result -> Map.get(result, :name) end)

      assert results == ["1", "3", "4", "2"]
    end

    test "desc" do
      insert(:product, name: "AAA")
      insert(:product, name: "DDD")
      insert(:product, name: "BBB")
      insert(:product, name: "CCC")

      op = [{:name, :desc}]

      results =
        ProductTable
        |> ProductDomain.sort_by(op)
        |> ProductDomain.repo().all()
        |> Enum.map(fn result -> Map.get(result, :name) end)

      assert results == ["DDD", "CCC", "BBB", "AAA"]
    end

    test "desc by association" do
      insert(:product, name: "1", category: insert(:category, title: "AAA"))
      insert(:product, name: "2", category: insert(:category, title: "DDD"))
      insert(:product, name: "3", category: insert(:category, title: "BBB"))
      insert(:product, name: "4", category: insert(:category, title: "CCC"))

      op = [{:category_title, :desc}]

      results =
        ProductTable
        |> ProductDomain.sort_by(op)
        |> ProductDomain.repo().all()
        |> Enum.map(fn result -> Map.get(result, :name) end)

      assert results == ["2", "4", "3", "1"]
    end
  end

  describe "#sort_validate" do
    test "clean valid sorts" do
      {:ok, sort} =
        ProductDomain.sort_validate([
          {:id, :asc},
          {"name", "asc"}
        ])

      assert sort == [{:id, :asc}, {"name", "asc"}]
    end

    test "fail on first invalid field" do
      {:error, reason} =
        ProductDomain.sort_validate([
          {:id, :asc},
          {"name", "asc"},
          {:unknown, :desc},
          {"wrong", :desc}
        ])

      assert reason == "Invalid sort : Invalid field : unknown"
    end

    test "fail on invalid format" do
      {:error, reason} =
        ProductDomain.sort_validate([
          {:id, :asc},
          {"name", "asc"},
          "WRONG"
        ])

      assert reason == "Invalid sort : Invalid sort format"
    end
  end

  describe "#sort_clean" do
    test "clean valid sorts" do
      sort =
        ProductDomain.sort_clean([
          {:id, :asc},
          {"name", "asc"}
        ])

      assert sort == [{:id, :asc}, {"name", "asc"}]
    end

    test "remove invalid sorts" do
      sort =
        ProductDomain.sort_clean([
          {:id, :asc},
          {"name", "asc"},
          {:unknown, :desc},
          {"wrong", :desc},
          "WRONG"
        ])

      assert sort == [{:id, :asc}, {"name", "asc"}]
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
        |> ProductDomain.find(product.id)

      assert record.category.id == category.id
    end

    test "it should load the variants" do
      product = insert(:product)
      first = insert(:variant, product: product)
      last = insert(:variant, product: product)

      {:ok, record} =
        ProductTable
        |> ProductDomain.preload_with(:variants)
        |> ProductDomain.find(product.id)

      ids = Enum.map(record.variants, fn variant -> variant.id end)
      assert ids == [first.id, last.id]
    end
  end
end
