defmodule DomainLogic.SortLib do
  @moduledoc false

  import Ecto.Query

  alias DomainLogic.SortLib

  @type sort_field :: {atom, true}
  @type sort :: {atom | String.t(), :asc | :desc | String.t()}

  @callback sort_fields() :: list(sort_field)
  @callback sort_by(Ecto.Schema.t(), sort | list(sort)) :: Ecto.Queryable.t()
  @callback sort_clean(sort | list(sort)) :: list(sort)
  @callback sort_validate(sort | list(sort)) :: {:ok, list(sort)} | {:error, String.t()}

  defmacro __using__(_opts) do
    quote do
      import DomainLogic.SortLib

      @behaviour DomainLogic.SortLib

      @impl true
      @spec sort_fields() :: list(SortLib.sort_field())
      def sort_fields, do: []
      defoverridable sort_fields: 0

      @impl true
      @spec sort_by(Ecto.Queryable.t(), SortLib.sort() | list(SortLib.sort())) ::
              Ecto.Queryable.t()
      def sort_by(query, sorts) when is_list(sorts) do
        fields = sort_fields()
        SortLib.__sort_builder__(query, sorts, fields)
      end

      def sort_by(query, sort), do: sort_by(query, [sort])

      @impl true
      @spec sort_clean(SortLib.sort() | list(SortLib.sort())) :: list(SortLib.sort())
      def sort_clean(sorts) when is_list(sorts) do
        fields = sort_fields()

        []
        |> SortLib.__sort_cleaner__(sorts, fields)
        |> Enum.reverse()
      end

      def sort_clean(sort), do: sort_clean([sort])

      @impl true
      @spec sort_validate(SortLib.sort() | list(SortLib.sort())) ::
              {:ok, list(SortLib.sort())} | {:error, String.t()}
      def sort_validate(sorts) when is_list(sorts) do
        fields = sort_fields()

        case SortLib.__sort_validator__([], sorts, fields) do
          {:error, reason} ->
            {:error, "Invalid sort : #{reason}"}

          sorts ->
            {:ok, Enum.reverse(sorts)}
        end
      end

      def sort_validate(sort), do: sort_validate([sort])
    end
  end

  defmacro register_sort(do: block) do
    quote do
      Module.register_attribute(__MODULE__, :sort_fields, accumulate: true)

      unquote(block)

      @impl true
      def sort_fields, do: Enum.reverse(@sort_fields)
    end
  end

  defmacro sort(name) do
    quote do
      Module.put_attribute(__MODULE__, :sort_fields, {unquote(name), true})
    end
  end

  @doc false
  def __sort_builder__(query, [], _fields), do: query

  def __sort_builder__(query, [{name, dir} | tail], fields) do
    with {:ok, name} <- validate_field_name(fields, name),
         {:ok, dir} <- validate_field_dir(dir) do
      query
      |> sort_builder_item(name, dir)
      |> __sort_builder__(tail, fields)
    else
      {:error, reason} ->
        raise ArgumentError, "Invalid sort : #{reason}"
    end
  end

  @doc false
  def __sort_cleaner__(acc, [], _fields), do: acc

  def __sort_cleaner__(acc, [{name, dir} | tail], fields) do
    with {:ok, name} <- validate_field_name(fields, name),
         {:ok, dir} <- validate_field_dir(dir) do
      __sort_cleaner__([{name, dir} | acc], tail, fields)
    else
      {:error, _reason} ->
        __sort_cleaner__(acc, tail, fields)
    end
  end

  def __sort_cleaner__(acc, [_ | tail], fields) do
    __sort_cleaner__(acc, tail, fields)
  end

  @doc false
  def __sort_validator__(acc, [], _fields), do: acc

  def __sort_validator__(acc, [{name, dir} | tail], fields) do
    with {:ok, name} <- validate_field_name(fields, name),
         {:ok, dir} <- validate_field_dir(dir) do
      __sort_validator__([{name, dir} | acc], tail, fields)
    end
  end

  def __sort_validator__(_acc, _sorts, _fields) do
    {:error, "Invalid format"}
  end

  defp sort_builder_item(query, name, dir) do
    case dir do
      :asc -> from(q in query, order_by: [asc: field(q, ^name)])
      _ -> from(q in query, order_by: [desc: field(q, ^name)])
    end
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

  defp validate_field_dir(dir) when dir in [:asc, :desc] do
    {:ok, dir}
  end

  defp validate_field_dir(dir) when dir in ["asc", "desc"] do
    {:ok, String.to_atom(dir)}
  end

  defp validate_field_dir(dir) do
    {:error, "Invalid operation : #{dir}"}
  end
end
