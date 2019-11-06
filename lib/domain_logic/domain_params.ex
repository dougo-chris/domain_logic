defmodule DomainLogic.DomainParams do
  @moduledoc false

  alias DomainLogic.FilterLib
  alias DomainLogic.SortLib

  ############################################################
  ## PAGINATION_PARAMS
  @page_size 10
  def pagination(params) do
    {
      Map.get(params, "page", 1),
      Map.get(params, "page_size", @page_size)
    }
  end

  ############################################################
  ## FILTER
  @spec filter(map(), (list(FilterLib.filter()) -> list(FilterLib.filter()))) ::
          list(FilterLib.filter()) | FilterLib.filter()
  def filter(params, cleaner) do
    cleaner.(filter(params))
  end

  defp filter(%{"filter_field" => field, "filter_op" => op, "filter_value" => value}) do
    [{Macro.underscore(field), op, value}]
  end

  defp filter(%{"filter" => %{"field" => field, "op" => op, "value" => value}}) do
    [{Macro.underscore(field), op, value}]
  end

  defp filter(%{"filter" => filter}) when is_list(filter) do
    filter
    |> Enum.map(fn
      %{"field" => field, "op" => op, "value" => value} ->
        {Macro.underscore(field), op, value}

      _ ->
        nil
    end)
    |> Enum.reject(&is_nil/1)
  end

  defp filter(%{"filter" => filter}) when is_map(filter) do
    filter
    |> Enum.map(fn
      {_, %{"field" => field, "op" => op, "value" => value}} ->
        {Macro.underscore(field), op, value}

      _ ->
        nil
    end)
    |> Enum.reject(&is_nil/1)
  end

  defp filter(_), do: []

  ############################################################
  ## SORT
  @spec sort(map(), (list(SortLib.sort()) -> list(SortLib.sort()))) ::
          list(SortLib.sort()) | SortLib.sort()
  def sort(params, cleaner) do
    cleaner.(sort(params))
  end

  defp sort(%{"sort_field" => field, "sort_dir" => dir}) do
    [{Macro.underscore(field), dir}]
  end

  defp sort(%{"sort" => %{"field" => field, "dir" => dir}}) do
    [{Macro.underscore(field), dir}]
  end

  defp sort(%{"sort" => %{"field" => field}}) do
    [{Macro.underscore(field), :asc}]
  end

  defp sort(%{"sort" => sort}) when is_list(sort) do
    sort
    |> Enum.map(fn
      %{"field" => field, "dir" => dir} ->
        {Macro.underscore(field), dir}
      %{"field" => field} ->
        {Macro.underscore(field), :asc}
      _ -> nil
    end)
    |> Enum.reject(&is_nil/1)
  end

  defp sort(%{"sort" => sort}) when is_map(sort) do
    sort
    |> Enum.map(fn
      {_, %{"field" => field, "dir" => dir}} ->
        {Macro.underscore(field), dir}

      {_, %{"field" => field}} ->
        {Macro.underscore(field), :asc}

      _ ->
        nil
    end)
    |> Enum.reject(&is_nil/1)
  end

  defp sort(_), do: []
end
