# DomainLogic

This library is a separation of the database table definition
and the logic for accessing a domain made up of a table or group of tables.

## Usage
Given an Ecto Table definitions
```
  defmodule MyApp.Db.ProductTable do
    @moduledoc false

    use Ecto.Schema

    schema "products" do
      field(:name, :string)
      field(:price, :integer)
      field(:available, :boolean)

      belongs_to(:category, MyApp.Db.CategoryTable, foreign_key: :category_id)
      has_many(:variants, MyApp.Db.VariantTable, foreign_key: :product_id)
    end
  end
```

Create a domain definition to access the table via the repo
```
  defmodule MyApp.Db.ProductDomain do
    @moduledoc false

    use DomainLogic.Domain,
      repo: MyApp.Repo,
      table: MyApp.Db.ProductTable

    register_filter do
      filter(:id, :integer)
      filter(:name, :string)
      filter(:price, :integer)
      filter(:available, :boolean)
      filter(:category_title, :string, association: :category, source: :title)
      filter(:category_code, :integer, association: :category, source: :code)
    end

    register_sort do
      sort(:id)
      sort(:name)
      sort(:price)
      sort(:category_title, association: :category, source: :title)
      sort(:category_code, association: :category, source: :code)
    end
  end
```

Now we can access the data with with finds, filters, sorts, preloading, pagination, count & all

```
alias MyApp.Db.ProductTable
alias MyApp.Db.ProductDomain

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
{:ok, product} = ProductDomain.find(1001)
{:ok, product} = ProductDomain.find({:id, 1001})
{:ok, product} = ProductDomain.find(ProductDomain, 1001)
{:ok, product} = ProductDomain.find(ProductDomain, {:id, 1001})
```

### Get one record
Note : If there are more than one record an exception is raised
```
{:ok, product} = ProductDomain.one()
{:ok, product} = ProductDomain.one(ProductTable)
```

### Get all records
```
products = ProductDomain.all()
products = ProductDomain.all(ProductTable)
```

### Pagination
We use the scriviner from [https://github.com/drewolson/scrivener_ecto]

```
products = ProductDomain.paginate({page, page_size})
products = ProductDomain.paginate(ProductTable, {page, page_size})
```

### Counting the records
```
counter = ProductDomain.count()
counter = ProductDomain.count(InterfaceTable)
counter = ProductDomain.count(InterfaceTable, :name)
```

### Filtering
Fields that can be filtered are listed with the field type
```
  register_filter do
    filter(:id, :integer)
    filter(:name, :string)
    filter(:hostname, :string, association: :device_record)
    filter(:device_management_ip, :integer, association: :device_record, source: :management_ip)
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
    sort(:hostname, :string, association: :device_record)
    sort(:device_management_ip, :integer, association: :device_record, source: :management_ip)
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
  |> join(:inner, [p], c in CategoryTable, on p.category_id == c.id)
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