defmodule Linklab.DomainLogic.FilterLib do
  @moduledoc """
    Functions and macros for filtering data

    Filters are structured as {field, op, value}
    - field is the field in the **register_filter**
    - operation in :gt, :ge, :lt, :le, :lk, :in, :ni, :ne, :eq

    ## Examples

        filter_by({:name, :eq, "Chris"})
        filter_by([{:name, :gt, "A"}, {:age, :lt, 40}])
  """

  import Ecto.Query

  alias Linklab.DomainLogic.FilterLib
  alias Linklab.DomainLogic.Filter.FilterString
  alias Linklab.DomainLogic.Filter.FilterInteger
  alias Linklab.DomainLogic.Filter.FilterDate
  alias Linklab.DomainLogic.Filter.FilterDatetime
  alias Linklab.DomainLogic.Filter.FilterBoolean

  @type filter_type :: :integer | :string
  @type filter_field :: {atom, filter_type}
  @type filter :: {atom | String.t(), :gt | :ge | :lt | :le | :lk | :in | :ni | :ne | :eq | String.t(), any()}

  @callback filter_fields() :: list(filter_field)
  @callback filter_by(Ecto.Schema.t(), filter | list(filter)) :: Ecto.Queryable.t()
  @callback filter_clean(filter | list(filter)) :: list(filter)
  @callback filter_validate(filter | list(filter)) :: {:ok, list(filter)} | {:error, String.t}

  defmacro __using__(_opts) do
    quote do
      import Linklab.DomainLogic.FilterLib

      @behaviour Linklab.DomainLogic.FilterLib

      @impl true
      @spec filter_fields() :: list(FilterLib.filter_field())
      def filter_fields, do: []
      defoverridable filter_fields: 0

      @impl true
      @spec filter_by(Ecto.Queryable.t(), FilterLib.filter() | list(FilterLib.filter())) :: Ecto.Queryable.t()
      def filter_by(query, filters) when is_list(filters) do
        fields = filter_fields()
        Linklab.DomainLogic.FilterLib.__filter_builder__(query, filters, fields)
      end

      def filter_by(query, filter), do: filter_by(query, [filter])

      @impl true
      @spec filter_clean(FilterLib.filter() | list(FilterLib.filter())) :: list(FilterLib.filter())
      def filter_clean(filters) when is_list(filters) do
        fields = filter_fields()

        []
        |> Linklab.DomainLogic.FilterLib.__filter_cleaner__(filters, fields)
        |> Enum.reverse()
      end

      def filter_clean(filter), do: filter_clean([filter])

      @impl true
      @spec filter_validate(FilterLib.filter() | list(FilterLib.filter())) :: {:ok, list(FilterLib.filter())} | {:error, String.t}
      def filter_validate(filters) when is_list(filters) do
        fields = filter_fields()

        case Linklab.DomainLogic.FilterLib.__filter_validator__([], filters, fields) do
          {:error, reason} ->
            {:error, "Invalid filter : #{reason}"}
          filters ->
            {:ok, Enum.reverse(filters)}
        end
      end

      def filter_validate(filter), do: filter_clean([filter])
    end
  end

  @doc """
  Define the filter_by fields
  """
  defmacro register_filter(do: block) do
    quote do
      Module.register_attribute(__MODULE__, :filter_fields, accumulate: true)

      unquote(block)

      @doc """
      A keyword list of filters and the source field
      """
      @impl true
      def filter_fields, do: Enum.reverse(@filter_fields)
    end
  end

  @doc """
  Define the filter_by field
  """
  @spec filter(atom, FilterLib.filter_type()) :: any()
  defmacro filter(name, type) do
    quote do
      Module.put_attribute(__MODULE__, :filter_fields, {unquote(name), unquote(type)})
    end
  end

  @doc false
  def __filter_builder__(query, [], _fields), do: query

  def __filter_builder__(query, [{name, op, value} | tail], fields) do
    with {:ok, name} <- validate_field_name(fields, name),
         {:ok, op} <- validate_field_op(op, Keyword.get(fields, name)),
         {:ok, value} <- validate_field_value(value, Keyword.get(fields, name), op) do
      query
      |> filter_builder_item(name, op, value)
      |> __filter_builder__(tail, fields)
    else
      {:error, reason} ->
        raise ArgumentError, reason
    end
  end

  @doc false
  def __filter_cleaner__(acc, [], _fields), do: acc

  def __filter_cleaner__(acc, [{name, op, value} | tail], fields) do
    with {:ok, name} <- validate_field_name(fields, name),
         {:ok, op} <- validate_field_op(op, Keyword.get(fields, name)),
         {:ok, value} <- validate_field_value(value, Keyword.get(fields, name), op) do
      __filter_cleaner__([{name, op, value} | acc], tail, fields)
    else
      {:error, _reason} ->
        __filter_cleaner__(acc, tail, fields)
    end
  end

  def __filter_cleaner__(acc, [_ | tail], fields) do
    __filter_cleaner__(acc, tail, fields)
  end

  @doc false
  def __filter_validator__(acc, [], _fields), do: acc

  def __filter_validator__(acc, [{name, op, value} | tail], fields) do
    with {:ok, name} <- validate_field_name(fields, name),
         {:ok, op} <- validate_field_op(op, Keyword.get(fields, name)),
         {:ok, value} <- validate_field_value(value, Keyword.get(fields, name), op) do
      __filter_validator__([{name, op, value} | acc], tail, fields)
    end
  end

  def __filter_validator__(_acc, _filter, _fields) do
    {:error, "Invalid format"}
  end

  defp filter_builder_item(query, name, :gt, value) do
    from(q in query, where: field(q, ^name) > ^value)
  end

  defp filter_builder_item(query, name, :ge, value) do
    from(q in query, where: field(q, ^name) >= ^value)
  end

  defp filter_builder_item(query, name, :lt, value) do
    from(q in query, where: field(q, ^name) < ^value)
  end

  defp filter_builder_item(query, name, :le, value) do
    from(q in query, where: field(q, ^name) <= ^value)
  end

  defp filter_builder_item(query, name, :lk, value) do
    from(q in query, where: like(field(q, ^name), ^"%#{value}%"))
  end

  defp filter_builder_item(query, name, :in, value) do
    from(q in query, where: field(q, ^name) in ^value)
  end

  defp filter_builder_item(query, name, :ni, value) do
    from(q in query, where: field(q, ^name) not in ^value)
  end

  defp filter_builder_item(query, name, :ne, nil) do
    from(q in query, where: not is_nil(field(q, ^name)))
  end

  defp filter_builder_item(query, name, :ne, value) do
    from(q in query, where: field(q, ^name) != ^value)
  end

  defp filter_builder_item(query, name, _op, nil) do
    from(q in query, where: is_nil(field(q, ^name)))
  end

  defp filter_builder_item(query, name, _op, value) do
    from(q in query, where: field(q, ^name) == ^value)
  end

  defp validate_field_name(fields, name) when is_atom(name) do
    case Keyword.get(fields, name) do
      nil ->
        {:error, "Invalid field : #{name}"}

      _ ->
        {:ok, name}
    end
  end

  defp validate_field_name(fields, name) do
    case Enum.find(fields, fn {field, _} -> "#{field}" == name end) do
      nil ->
        {:error, "Invalid field : #{name}"}

      {name, _} ->
        {:ok, name}
    end
  end

  defp validate_field_op(op, type) when op in ["gt", "ge", "lt", "le", "lk", "in", "ne", "eq"] do
    validate_field_op(String.to_atom(op), type)
  end

  defp validate_field_op(op, :boolean) when op not in [:ne, :eq] do
    {:error, "Invalid operation : #{op}"}
  end

  defp validate_field_op(op, :date) when op not in [:gt, :ge, :lt, :le, :ne, :eq] do
    {:error, "Invalid operation : #{op}"}
  end

  defp validate_field_op(op, :datetime) when op not in [:gt, :ge, :lt, :le, :ne, :eq] do
    {:error, "Invalid operation : #{op}"}
  end

  defp validate_field_op(:lk, :integer) do
    {:error, "Invalid operation : lk"}
  end

  defp validate_field_op(op, _type) when op in [:gt, :ge, :lt, :le, :lk, :in, :ni, :ne, :eq] do
    {:ok, op}
  end

  defp validate_field_op(op, _type) do
    {:error, "Invalid operation : #{op}"}
  end

  # STRING
  defp validate_field_value(value, type, op) do
    case type do
      :string ->
        FilterString.validate_value(value, op)

      :integer ->
        FilterInteger.validate_value(value, op)

      :boolean ->
        FilterBoolean.validate_value(value, op)

      :date ->
        FilterDate.validate_value(value, op)

      :datetime ->
        FilterDatetime.validate_value(value, op)

      _ ->
        {:error, "Invalid filter type"}
    end
  end
end
