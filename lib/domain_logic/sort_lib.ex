defmodule Linklab.DomainLogic.SortLib do
  @moduledoc false

  import Ecto.Query

  @callback sort_fields() :: list()
  @callback sort_fields(:associations) :: list()
  @callback sort_by(Ecto.Schema.t(), any()) :: any()

  defmacro __using__(_opts) do
    quote do
      import Linklab.DomainLogic.SortLib

      @behaviour Linklab.DomainLogic.SortLib

      @impl true
      def sort_fields, do: []
      @impl true
      def sort_fields(:associations), do: []
      defoverridable sort_fields: 0, sort_fields: 1

      @type sort :: {atom | String.t(), :asc | :desc | String.t()}

      @impl true
      @spec sort_by(Ecto.Queryable.t(), sort | list(sort)) :: Ecto.Queryable.t()
      def sort_by(query, sorts) when is_list(sorts) do
        fields = sort_fields()
        associations = sort_fields(:associations)

        Linklab.DomainLogic.SortLib.__sort_builder__(query, sorts, fields, associations)
      end

      def sort_by(query, sort), do: sort_by(query, [sort])
    end
  end

  defmacro register_sort(do: block) do
    quote do
      Module.register_attribute(__MODULE__, :sort_fields, accumulate: true)
      Module.register_attribute(__MODULE__, :sort_field_associations, accumulate: true)

      unquote(block)

      @impl true
      def sort_fields, do: Enum.reverse(@sort_fields)

      @impl true
      def sort_fields(:associations), do: Enum.reverse(@sort_field_associations)
    end
  end

  defmacro sort(name, options \\ []) do
    field_name = options[:source] || name
    association = options[:association] || false

    quote do
      Module.put_attribute(__MODULE__, :sort_fields, {unquote(name), unquote(field_name)})

      if unquote(association) do
        Module.put_attribute(__MODULE__, :sort_field_associations, {unquote(name), unquote(association)})
      end
    end
  end

  @doc false
  def __sort_builder__(query, [], _fields, _associations), do: query

  def __sort_builder__(query, [{name, dir} | tail], fields, associations) do
    with {:ok, name} <- validate_field_name(fields, name),
         {:ok, dir} <- validate_field_dir(dir) do
      query
      |> sort_builder_item(fields[name], dir, associations[name])
      |> __sort_builder__(tail, fields, associations)
    else
      {:error, reason} -> raise ArgumentError, "Invalid sort : #{reason}"
    end
  end

  defp sort_builder_item(query, name, dir, nil) do
    case dir do
      :asc -> from(q in query, order_by: [asc: field(q, ^name)])
      _ -> from(q in query, order_by: [desc: field(q, ^name)])
    end
  end

  defp sort_builder_item(query, name, dir, association) do
    case dir do
      :asc -> from(q in query, join: ac in assoc(q, ^association), order_by: [asc: field(ac, ^name)])
      _ -> from(q in query, join: ac in assoc(q, ^association), order_by: [desc: field(ac, ^name)])
    end
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

  defp validate_field_dir(dir) when dir in [:asc, :desc], do: {:ok, dir}
  defp validate_field_dir(dir) when dir in ["asc", "desc"], do: {:ok, String.to_atom(dir)}

  defp validate_field_dir(dir) do
    {:error, "Invalid dir : #{dir}"}
  end
end
