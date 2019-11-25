defmodule DomainLogic.Domain.FilterLib do
  @moduledoc """
    Functions and macros for filtering data

    Filters are structured as {field, op, value}
    - field is the field in the **register_filter**
    - operation in :gt, :ge, :lt, :le, :lk, :in, :ne, :eq

    ## Examples

        filter_by({:name, :eq, "Chris"})
        filter_by([{:name, :gt, "A"}, {:age, :lt, 40}])
  """

  import Ecto.Query

  alias DomainLogic.Domain.Filter.FilterBoolean
  alias DomainLogic.Domain.Filter.FilterDate
  alias DomainLogic.Domain.Filter.FilterDatetime
  alias DomainLogic.Domain.Filter.FilterInteger
  alias DomainLogic.Domain.Filter.FilterString
  alias DomainLogic.Domain.FilterLib

  @type filter_type :: :integer | :string
  @type filter_field :: {atom, filter_type}
  @type filter :: {atom | String.t(), :gt | :ge | :lt | :le | :lk | :in | :ne | :eq | String.t(), any()}

  @callback filter_fields() :: list(filter_field)
  @callback filter_by(Ecto.Schema.t(), filter | list(filter)) :: Ecto.Queryable.t()
  @callback filter_validate(filter | list(filter)) :: {:ok, list(filter)} | {:error, String.t()}
  @callback filter_clean(filter | list(filter)) :: list(filter)

  defmacro __using__(_opts) do
    quote do
      import DomainLogic.Domain.FilterLib

      @behaviour DomainLogic.Domain.FilterLib

      @impl true
      @spec filter_fields() :: list(FilterLib.filter_field())
      def filter_fields, do: []
      defoverridable filter_fields: 0

      @impl true
      @spec filter_by(Ecto.Queryable.t(), FilterLib.filter() | list(FilterLib.filter())) :: Ecto.Queryable.t()
      def filter_by(query, filters) when is_list(filters) do
        fields = filter_fields()
        FilterLib.__filter_builder__(query, filters, fields)
      end

      def filter_by(query, filter), do: filter_by(query, [filter])

      @impl true
      @spec filter_validate(FilterLib.filter() | list(FilterLib.filter())) ::
              {:ok, list(FilterLib.filter())} | {:error, String.t()}
      def filter_validate(filters) when is_list(filters) do
        fields = filter_fields()

        case FilterLib.__filter_validator__([], filters, fields) do
          {:error, reason} ->
            {:error, "Invalid filter : #{reason}"}

          filters ->
            {:ok, Enum.reverse(filters)}
        end
      end

      def filter_validate(filter), do: filter_validate([filter])

      @impl true
      @spec filter_clean(FilterLib.filter() | list(FilterLib.filter())) :: list(FilterLib.filter())
      def filter_clean(filters) when is_list(filters) do
        fields = filter_fields()

        []
        |> FilterLib.__filter_cleaner__(filters, fields)
        |> Enum.reverse()
      end

      def filter_clean(filter), do: filter_clean([filter])
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
  defmacro filter(name, field_type, options \\ []) do
    quote do
      Module.put_attribute(
        __MODULE__,
        :filter_fields,
        {
          unquote(name),
          {
            Keyword.get(unquote(options), :source, unquote(name)),
            unquote(field_type),
            Keyword.get(unquote(options), :association)
          }
        }
      )
    end
  end

  @doc false
  def __filter_builder__(query, [], _fields), do: query

  def __filter_builder__(query, [{name, op, value} | tail], fields) do
    with {:ok, {field_name, field_type, field_association}} <- validate_field_name(fields, name),
         {:ok, field_op} <- validate_field_op(op, field_type),
         {:ok, field_value} <- validate_field_value(field_type, field_op, value) do
      query
      |> filter_builder_item(field_name, field_op, field_value, field_association)
      |> __filter_builder__(tail, fields)
    else
      {:error, reason} ->
        raise ArgumentError, reason
    end
  end

  @doc false
  def __filter_validator__(acc, [], _fields), do: acc

  def __filter_validator__(acc, [{name, op, value} | tail], fields) do
    with {:ok, {_field_name, field_type, _field_association}} <- validate_field_name(fields, name),
         {:ok, field_op} <- validate_field_op(op, field_type),
         {:ok, _field_value} <- validate_field_value(field_type, field_op, value) do
      __filter_validator__([{name, op, value} | acc], tail, fields)
    else
      error ->
        error
    end
  end

  def __filter_validator__(_acc, _filters, _fields) do
    {:error, "Invalid filter format"}
  end

  @doc false
  def __filter_cleaner__(acc, [], _fields), do: acc

  def __filter_cleaner__(acc, [{name, op, value} | tail], fields) do
    with {:ok, {_field_name, field_type, _field_association}} <- validate_field_name(fields, name),
         {:ok, field_op} <- validate_field_op(op, field_type),
         {:ok, _field_value} <- validate_field_value(field_type, field_op, value) do
      __filter_cleaner__([{name, op, value} | acc], tail, fields)
    else
      {:error, _reason} ->
        __filter_cleaner__(acc, tail, fields)
    end
  end

  def __filter_cleaner__(acc, [_ | tail], fields) do
    __filter_cleaner__(acc, tail, fields)
  end

  defp filter_builder_item(query, name, :gt, value, nil) do
    from(q in query, where: field(q, ^name) > ^value)
  end

  defp filter_builder_item(query, name, :ge, value, nil) do
    from(q in query, where: field(q, ^name) >= ^value)
  end

  defp filter_builder_item(query, name, :lt, value, nil) do
    from(q in query, where: field(q, ^name) < ^value)
  end

  defp filter_builder_item(query, name, :le, value, nil) do
    from(q in query, where: field(q, ^name) <= ^value)
  end

  defp filter_builder_item(query, name, :lk, value, nil) do
    from(q in query, where: like(field(q, ^name), ^"%#{value}%"))
  end

  defp filter_builder_item(query, name, :in, value, nil) do
    from(q in query, where: field(q, ^name) in ^value)
  end

  defp filter_builder_item(query, name, :ne, value, nil) do
    from(q in query, where: field(q, ^name) != ^value)
  end

  defp filter_builder_item(query, name, _op, value, nil) do
    from(q in query, where: field(q, ^name) == ^value)
  end

  defp filter_builder_item(query, name, :gt, value, association) do
    from(q in query, join: as in assoc(q, ^association), where: field(as, ^name) > ^value)
  end

  defp filter_builder_item(query, name, :ge, value, association) do
    from(q in query, join: as in assoc(q, ^association), where: field(as, ^name) >= ^value)
  end

  defp filter_builder_item(query, name, :lt, value, association) do
    from(q in query, join: as in assoc(q, ^association), where: field(as, ^name) < ^value)
  end

  defp filter_builder_item(query, name, :le, value, association) do
    from(q in query, join: as in assoc(q, ^association), where: field(as, ^name) <= ^value)
  end

  defp filter_builder_item(query, name, :lk, value, association) do
    from(q in query, join: as in assoc(q, ^association), where: like(field(as, ^name), ^"%#{value}%"))
  end

  defp filter_builder_item(query, name, :in, value, association) do
    from(q in query, join: as in assoc(q, ^association), where: field(as, ^name) in ^value)
  end

  defp filter_builder_item(query, name, :ne, value, association) do
    from(q in query, join: as in assoc(q, ^association), where: field(as, ^name) != ^value)
  end

  defp filter_builder_item(query, name, _, value, association) do
    from(q in query, join: as in assoc(q, ^association), where: field(as, ^name) == ^value)
  end

  defp validate_field_name(fields, name) when is_atom(name) do
    case Keyword.get(fields, name) do
      nil ->
        {:error, "Invalid field : #{name}"}

      field ->
        {:ok, field}
    end
  end

  defp validate_field_name(fields, name) do
    case Enum.find(fields, fn {field, _} -> "#{field}" == name end) do
      nil ->
        {:error, "Invalid filter field : #{name}"}

      {_, field} ->
        {:ok, field}
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
  defp validate_field_value(type, op, value) do
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
        {:error, "Invalid filter type : #{type}"}
    end
  end
end
