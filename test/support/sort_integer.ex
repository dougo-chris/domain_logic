defmodule Linklab.DomainLogic.Test.SortInteger do
  @moduledoc false

  defmacro test_sort_by_integer(domain, table, model, field) do
    quote do
      test_sort_by_integer(unquote(domain), unquote(table), unquote(model), unquote(field), %{})
    end
  end

  defmacro test_sort_by_integer(domain, table, model, field, params) do
    quote do
      presence = unquote(domain).sort_fields()[unquote(field)]
      assert presence == true

      ######################################
      # ASC
      ######################################
      r1 = insert(unquote(model), Map.put(unquote(params), unquote(field), 1001))
      r2 = insert(unquote(model), Map.put(unquote(params), unquote(field), 4004))
      r3 = insert(unquote(model), Map.put(unquote(params), unquote(field), 2002))
      r4 = insert(unquote(model), Map.put(unquote(params), unquote(field), 3003))

      op = [{unquote(field), :asc}]

      results =
        unquote(table)
        |> unquote(domain).sort_by(op)
        |> unquote(domain).repo().all()
        |> Enum.map(fn result -> Map.get(result, unquote(field)) end)

      assert results == [1001, 2002, 3003, 4004]

      unquote(domain).repo().delete(r1)
      unquote(domain).repo().delete(r2)
      unquote(domain).repo().delete(r3)
      unquote(domain).repo().delete(r4)

      ######################################
      # DESC
      ######################################
      r1 = insert(unquote(model), Map.put(unquote(params), unquote(field), 1001))
      r2 = insert(unquote(model), Map.put(unquote(params), unquote(field), 4004))
      r3 = insert(unquote(model), Map.put(unquote(params), unquote(field), 2002))
      r4 = insert(unquote(model), Map.put(unquote(params), unquote(field), 3003))

      op = [{unquote(field), :desc}]

      results =
        unquote(table)
        |> unquote(domain).sort_by(op)
        |> unquote(domain).repo().all()
        |> Enum.map(fn result -> Map.get(result, unquote(field)) end)

      assert results == [4004, 3003, 2002, 1001]

      unquote(domain).repo().delete(r1)
      unquote(domain).repo().delete(r2)
      unquote(domain).repo().delete(r3)
      unquote(domain).repo().delete(r4)
    end
  end
end
