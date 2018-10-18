defmodule Linklab.DomainLogic do
  @moduledoc false

  @callback find_fields() :: list

  defmacro __using__(opts) do
    repo = opts[:repo]
    table = opts[:table]

    quote do
      use Linklab.DomainLogic.FilterLib
      use Linklab.DomainLogic.SortLib
      use Linklab.DomainLogic.LimitLib
      use Linklab.DomainLogic.PreloadLib

      import Linklab.DomainLogic

      @behaviour Linklab.DomainLogic

      @impl true
      def find_fields, do: []
      defoverridable find_fields: 0

      @doc """
      Fetch a Records by the field == value
      """
      @spec find(atom | String.t(), any(), list()) :: Ecto.Queryable.t()
      def find(field, value, associations \\ []) do
        fields = find_fields()

        Linklab.DomainLogic.__find_builder__(unquote(repo), field, value, unquote(table), fields, associations)
      end

      @doc """
      Fetch one Record by the query
      """
      @spec one(Ecto.Queryable.t(), list()) :: Ecto.Queryable.t()
      def one(query, associations \\ []) do
        case unquote(repo).one(query) do
          nil ->
            table_name =
              "#{unquote(table)}"
              |> String.split(".")
              |> Enum.reverse()
              |> hd
              |> String.replace(~r/Table$/, "")

            {:error, "#{table_name} not found"}

          record ->
            {:ok, unquote(repo).preload(record, associations)}
          end
      end

      @doc """
      Fetch all Records by the query
      """
      @spec all(Ecto.Queryable.t(), list()) :: Ecto.Queryable.t()
      def all(query, associations \\ []) do
        query
        |> unquote(repo).all()
        |> unquote(repo).preload(associations)
      end

      @doc """
      Fetch a page of Records by the query
      """
      @spec paginate(Ecto.Queryable.t(), any(), list()) :: Scrivener.Page.t()
      def paginate(query, pagination, associations \\ []) do
        query
        |> unquote(repo).paginate(pagination)
        |> unquote(repo).preload(associations)
      end

      @doc """
      Count then Records by the query
      """
      @spec count(Ecto.Queryable.t()) :: integer
      def count(query) do
        unquote(repo).aggregate(query, :count, :id)
      end

      @doc """
      Repo used by the domain
      """
      @spec repo() :: Ecto.Repo.t()
      def repo() do
        unquote(repo)
      end
    end
  end

  @doc """
  Define the find fields
  """
  defmacro register_find(do: block) do
    quote do
      Module.register_attribute(__MODULE__, :find_fields, accumulate: true)

      unquote(block)

      @doc """
      A keyword list of filters and the source field
      """
      @impl true
      def find_fields, do: Enum.reverse(@find_fields)
    end
  end

  @doc """
  Define a find field
  """
  defmacro find(field, func \\ nil) do
    quote do
      Module.put_attribute(__MODULE__, :find_fields, {unquote(field), {:ok, unquote(func)}})
    end
  end

  @doc false
  def __find_builder__(repo, name, value, module, fields, associations \\ []) do
    case validate_func(name, fields) do
      {:ok, func} ->
        record =
          module
          |> repo.get_by([{name, func.(value)}])
          |> repo.preload(associations)

        case record do
          nil ->
            table_name =
              "#{module}"
              |> String.split(".")
              |> Enum.reverse()
              |> hd
              |> String.replace(~r/Table$/, "")

            {:error, "#{table_name} not found"}

          record ->
            {:ok, record}
        end

      _ ->
        raise ArgumentError, "Invalid find : #{name}"
    end
  end

  defp validate_func(name, fields) do
    case fields[name] do
      {:ok, nil} -> {:ok, &(&1)}
      {:ok, func} -> {:ok, func}
      _ -> {:error, "Field not findable"}
    end
  end
end
