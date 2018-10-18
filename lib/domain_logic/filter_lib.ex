defmodule Linklab.DomainLogic.FilterLib do
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

  alias Linklab.DomainLogic.Filter.FilterString
  alias Linklab.DomainLogic.Filter.FilterInteger
  alias Linklab.DomainLogic.Filter.FilterDate
  alias Linklab.DomainLogic.Filter.FilterDatetime
  alias Linklab.DomainLogic.Filter.FilterBoolean

  @callback filter_fields() :: list()
  @callback filter_fields(:types | :associations) :: list()
  @callback filter_by(Ecto.Schema.t(), any()) :: any()

  defmacro __using__(_opts) do
    quote do
      import Linklab.DomainLogic.FilterLib

      @type filter :: {atom | String.t(), :gt | :ge | :lt | :le | :lk | :in | :ne | :eq | String.t(), any()}

      @behaviour Linklab.DomainLogic.FilterLib
      @impl true
      def filter_fields, do: []
      @impl true
      def filter_fields(_), do: []
      defoverridable filter_fields: 0, filter_fields: 1

      @impl true
      @spec filter_by(Ecto.Queryable.t(), filter | list(filter)) :: Ecto.Queryable.t()
      def filter_by(query, filters) when is_list(filters) do
        fields = filter_fields()
        types = filter_fields(:types)
        associations = filter_fields(:associations)

        Linklab.DomainLogic.FilterLib.__filter_builder__(query, filters, fields, types, associations)
      end

      def filter_by(query, filter), do: filter_by(query, [filter])
    end
  end

  @doc """
  Define the filter_by fields
  """
  defmacro register_filter(do: block) do
    quote do
      Module.register_attribute(__MODULE__, :filter_fields, accumulate: true)
      Module.register_attribute(__MODULE__, :filter_field_types, accumulate: true)
      Module.register_attribute(__MODULE__, :filter_field_associations, accumulate: true)

      unquote(block)

      @doc """
      A keyword list of filters and the source field
      """
      @impl true
      def filter_fields, do: Enum.reverse(@filter_fields)

      @doc """
      A keyword list of filters and the definitions

      - :types
      - :associations
      """
      @impl true
      def filter_fields(:types), do: Enum.reverse(@filter_field_types)
      def filter_fields(:associations), do: Enum.reverse(@filter_field_associations)
    end
  end

  @doc """
  Define the filter_by field
  """
  # @spec filter(atom, atom, list) :: any
  defmacro filter(name, type, options \\ []) do
    field_name = options[:source] || name
    association = options[:association] || false

    quote do
      Module.put_attribute(__MODULE__, :filter_fields, {unquote(name), unquote(field_name)})
      Module.put_attribute(__MODULE__, :filter_field_types, {unquote(name), unquote(type)})

      if unquote(association) do
        Module.put_attribute(__MODULE__, :filter_field_associations, {unquote(name), unquote(association)})
      end
    end
  end

  @doc false
  def __filter_builder__(query, [], _fields, _types, _associations), do: query

  def __filter_builder__(query, [{name, op, value} | tail], fields, types, associations) do
    with {:ok, name} <- validate_field_name(fields, name),
         {:ok, op} <- validate_field_op(op),
         {:ok, value} <- validate_field_value(value, types[name], op) do
      query
      |> filter_builder_item(fields[name], op, value, associations[name])
      |> __filter_builder__(tail, fields, types, associations)
    else
      {:error, reason} ->
        raise ArgumentError, reason
    end
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

  defp filter_builder_item(query, name, :eq, value, nil) do
    from(q in query, where: field(q, ^name) == ^value)
  end

  defp filter_builder_item(query, name, :gt, value, association) do
    from(q in query, join: ac in assoc(q, ^association), where: field(ac, ^name) > ^value)
  end

  defp filter_builder_item(query, name, :ge, value, association) do
    from(q in query, join: ac in assoc(q, ^association), where: field(ac, ^name) >= ^value)
  end

  defp filter_builder_item(query, name, :lt, value, association) do
    from(q in query, join: ac in assoc(q, ^association), where: field(ac, ^name) < ^value)
  end

  defp filter_builder_item(query, name, :le, value, association) do
    from(q in query, join: ac in assoc(q, ^association), where: field(ac, ^name) <= ^value)
  end

  defp filter_builder_item(query, name, :lk, value, association) do
    from(q in query, join: ac in assoc(q, ^association), where: like(field(ac, ^name), ^"%#{value}%"))
  end

  defp filter_builder_item(query, name, :in, value, association) do
    from(q in query, join: ac in assoc(q, ^association), where: field(ac, ^name) in ^value)
  end

  defp filter_builder_item(query, name, :ne, value, association) do
    from(q in query, join: ac in assoc(q, ^association), where: field(ac, ^name) != ^value)
  end

  defp filter_builder_item(query, name, :eq, value, association) do
    from(q in query, join: ac in assoc(q, ^association), where: field(ac, ^name) == ^value)
  end

  defp filter_builder_item(_query, name, op, _value, _association) do
    raise ArgumentError, "invalid filter : #{name} : #{op}"
  end

  defp validate_field_name(fields, name) when is_atom(name) do
    case fields[name] do
      nil -> {:error, "Invalid field : #{name}"}
      _ -> {:ok, name}
    end
  end

  defp validate_field_name(fields, name) do
    case Enum.find(fields, fn {field, _} -> "#{field}" == name end) do
      nil -> {:error, "Invalid field : #{name}"}
      {name, _} -> {:ok, name}
    end
  end

  defp validate_field_op(op) when op in [:gt, :ge, :lt, :le, :lk, :in, :ne, :eq], do: {:ok, op}
  defp validate_field_op(op) when op in ["gt", "ge", "lt", "le", "lk", "in", "ne", "eq"], do: {:ok, String.to_atom(op)}

  defp validate_field_op(op) do
    {:error, "Invalid operation : #{op}"}
  end

  # STRING
  defp validate_field_value(value, type, op) do
    case type do
      :string ->
        FilterString.validate_value(value, op)

      :integer ->
        FilterInteger.validate_value(value, op)

      :date ->
        FilterDate.validate_value(value, op)

      :datetime ->
        FilterDatetime.validate_value(value, op)

      :boolean ->
        FilterBoolean.validate_value(value, op)

      _ ->
        {:error, "Invalid filter type"}
    end
  end
end
