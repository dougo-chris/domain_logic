defmodule Linklab.DomainLogic.Test.SortString do
  defmacro test_sort_by_string(domain, table, model, field) do
    quote do
      test_sort_by_string(unquote(domain), unquote(table), unquote(model), unquote(field), %{})
    end
  end

  defmacro test_sort_by_string(domain, table, model, field, params) do
    quote do
      presence = unquote(domain).sort_fields()[unquote(field)]
      assert presence == true

      ######################################
      # ASC
      ######################################
      r1 = insert(unquote(model), Map.put(unquote(params), unquote(field), "AAA"))
      r2 = insert(unquote(model), Map.put(unquote(params), unquote(field), "DDD"))
      r3 = insert(unquote(model), Map.put(unquote(params), unquote(field), "BBB"))
      r4 = insert(unquote(model), Map.put(unquote(params), unquote(field), "CCC"))

      op = [{unquote(field), :asc}]

      results =
        unquote(table)
        |> unquote(domain).sort_by(op)
        |> unquote(domain).repo().all()
        |> Enum.map(fn result -> Map.get(result, unquote(field)) end)

      assert results == ["AAA", "BBB", "CCC", "DDD"]

      unquote(domain).repo().delete(r1)
      unquote(domain).repo().delete(r2)
      unquote(domain).repo().delete(r3)
      unquote(domain).repo().delete(r4)

      ######################################
      # DESC
      ######################################
      r1 = insert(unquote(model), Map.put(unquote(params), unquote(field), "AAA"))
      r2 = insert(unquote(model), Map.put(unquote(params), unquote(field), "DDD"))
      r3 = insert(unquote(model), Map.put(unquote(params), unquote(field), "BBB"))
      r4 = insert(unquote(model), Map.put(unquote(params), unquote(field), "CCC"))

      op = [{unquote(field), :desc}]

      results =
        unquote(table)
        |> unquote(domain).sort_by(op)
        |> unquote(domain).repo().all()
        |> Enum.map(fn result -> Map.get(result, unquote(field)) end)

      assert results == ["DDD", "CCC", "BBB", "AAA"]

      unquote(domain).repo().delete(r1)
      unquote(domain).repo().delete(r2)
      unquote(domain).repo().delete(r3)
      unquote(domain).repo().delete(r4)
    end
  end
end
