# DomainLogic

This library is a separation of the database table definition
and the logic for accessing a domain made up of a table or group of tables.

## Usage
Given an Ecto Table definitions
```
  defmodule DomainLogic.Db.ProductTable do
    @moduledoc false

    use Ecto.Schema

    schema "products" do
      field(:name, :string)
      field(:price, :integer)
      field(:available, :boolean)

      belongs_to(:category, DomainLogic.Db.CategoryTable, foreign_key: :category_id)
      has_many(:variants, DomainLogic.Db.VariantTable, foreign_key: :product_id)
    end
  end
```

Create a domain definition to access the table
```
  defmodule DomainLogic.Db.ProductDomain do
    @moduledoc false

    use DomainLogic,
      repo: DomainLogic.Repo,
      table: DomainLogic.Db.ProductTable

    register_filter do
      filter(:id, :integer)
      filter(:name, :string)
      filter(:price, :integer)
      filter(:available, :boolean)
    end

    register_sort do
      sort(:id)
      sort(:name)
      sort(:price)
    end
  end
```

Now we can access the data with with finds, filters, sorts, preloading, pagination, count & all

```
alias DomainLogic.Db.ProductTable
alias DomainLogic.Db.ProductDomain

products =
  ProductTable
  |> ProductDomain.filter_by({:category_id, :eq, 1001})
  |> ProductDomain.sort_by(:name, :asc})
  |> ProductDomain.preload_with([:variants])
  |> ProductDomain.paginate({2, 20})
```

### Find by value
Note : If there are more than one record an exception is raised
```
{:ok, product} = ProductDomain.find(ProductTable, {:category_id, 1001})
```

### Get one record
Note : If there are more than one record an exception is raised
```
{:ok, product} = ProductDomain.one(ProductTable)
```

### Get all records
```
products = ProductDomain.all(ProductTable)
```

### Pagination
We use the scriviner from [https://github.com/drewolson/scrivener_ecto]

```
products = ProductDomain.paginate(ProductTable, {page, page_size})
```

### Counting the records
```
counter = ProductDomain.count(ProductTable)
```

### Filtering
Fields that can be filtered are listed with the field type
```
  register_filter do
    filter(:id, :integer)
    filter(:name, :string)
  end
```

The filter operations are `:gt`, `:ge`, `:lt`, `:le` `:lk`, `:in`, `:ne` and `:eq`

```
{:ok, product} =
  ProductTable
  |> ProductDomain.filter_by({:category_id, :eq, 1001})
  |> ProductDomain.all()
```

### Sorting
The domain defines the fields you can sort by
```
  register_sort do
    sort(:id)
    sort(:name)
  end
```

The sort operations are `:asc`, `:desc`

```
{:ok, product} =
  ProductTable
  |> ProductDomain.sort_by({:category_id, :asc})
  |> ProductDomain.all()
```

### Limiting
Get 100 records starting at the offset 10

```
{:ok, products} =
  ProductTable
  |> ProductDomain.limit_by({10, 100})
  |> ProductDomain.all()
  ...
```

or

Get 100 records at offset 0
```
{:ok, products} =
  ProductTable
  |> ProductDomain.limit_by(100)
  |> ProductDomain.all()
  ...
```

### Associations
Preload the associations

```
{:ok, product} =
  ProductTable
  |> ProductDomain.preload_with(:device)
  |> ProductDomain.all()
```

### Extending the Queries
```
import Ecto.Query

products =
  ProductTable
  |> join(:inner, [i], d in Device, on i.category_id == d.id)
  |> ProductDomain.all()
```

### Filters : Validating
Return an `:error` if the filter is invalid

```
{:error, reason} = ProductDomain.filter_validate([{:id, :eq, 1}, {:unknown, :wrong, ~r/value/}])
```

### Filters : Cleaning
Return a cleaned filter list

```
[{:id, :eq, 1}] = ProductDomain.filter_clean([{:id, :eq, 1}, {:unknown, :wrong, ~r/value/}])
```

### Sorts : Validating
Return an `:error` if the sort is invalid

```
{:error, reason} = ProductDomain.sort_validate([{:id, :asc}, {:unknown, :wrong}])
```

### Sorts : Cleaning
Return a cleaned sort list

```
[{:id, :asc}] = ProductDomain.sort_clean([{:id, :asc}, {:unknown, :wrong}])
```

## Coverting Query Params to Queries
DomainLogic.DomainParams will convert parameters (like in a API request) into valid query commands
```
  def index(conn, params) do
    category = conn.assigns[:current_category]

    filters = DomainParams.filter(params, &ProductDomain.filter_clean/1)
    sorts = DomainParams.sort(params, &ProductDomain.sort_clean/1)
    pagination = DomainParams.pagination(params)

    products =
      ProductTable
      |> ProductDomain.filter_by({:category_id, :eq, category.id})
      |> ProductDomain.filter_by(filters)
      |> ProductDomain.sort_by(sorts)
      |> ProductDomain.preload_with([:category, :variants])
      |> ProductDomain.paginate(pagination)

    render(conn, "index.json", products: products)
  end
```

## DEVELOPMENT
```./bin/domain_logic clean```     To clean runtime dependencies

```./bin/domain_logic build```     To install the dependencies

```./bin/domain_logic upgrade```   To upgrade the dependencies

```./bin/domain_logic iex```       To run the elixir command line

```./bin/domain_logic mix```       To run a mix task

## TESTING

```./bin/domain_logic test```            Run the tests

```./bin/domain_logic test dialyzer```   Execute dialyzer

```./bin/domain_logic test watch```      Continuously run the tests

```./bin/domain_logic test dev```        Continuously run the dev tests
