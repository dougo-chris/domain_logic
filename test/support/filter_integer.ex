defmodule Linklab.DomainLogic.Test.FilterInteger do
  @moduledoc false

  defmacro test_filter_by_integer(domain, table, model, field) do
    quote do
      test_filter_by_integer(unquote(domain), unquote(table), unquote(model), unquote(field), %{})
    end
  end

  defmacro test_filter_by_integer(domain, table, model, field, params) do
    # credo:disable-for-next-line Credo.Check.Refactor.LongQuoteBlocks
    quote do
      fields = unquote(domain).filter_fields()
      {_, field_type, _} = Enum.find(fields, fn {name, _, _} -> name == unquote(field) end)
      assert field_type == :integer

      ######################################
      # INVALID OP
      ######################################
      assert_raise ArgumentError, ~r/Invalid operation/, fn ->
        op = [{unquote(field), :invalid, 1111}]

        unquote(domain).filter_by(unquote(table), op)
      end

      ######################################
      # NOT AN INTEGER
      ######################################
      assert_raise ArgumentError, ~r/Invalid value/, fn ->
        op = [{unquote(field), :eq, "not good"}]

        unquote(domain).filter_by(unquote(table), op)
      end

      ######################################
      # CONVERT TO INTEGER
      ######################################
      r1 = insert(unquote(model), Map.put(unquote(params), unquote(field), 1001))
      r2 = insert(unquote(model), Map.put(unquote(params), unquote(field), 1111))
      r3 = insert(unquote(model), Map.put(unquote(params), unquote(field), 2002))

      op = [{unquote(field), :eq, "2002"}]

      results =
        unquote(table)
        |> unquote(domain).filter_by(op)
        |> unquote(domain).repo().all()
        |> Enum.map(fn result -> Map.get(result, unquote(field)) end)

      assert results == [2002]

      unquote(domain).repo().delete(r1)
      unquote(domain).repo().delete(r2)
      unquote(domain).repo().delete(r3)

      ######################################
      # EQ
      ######################################
      r1 = insert(unquote(model), Map.put(unquote(params), unquote(field), 1001))
      r2 = insert(unquote(model), Map.put(unquote(params), unquote(field), 1111))
      r3 = insert(unquote(model), Map.put(unquote(params), unquote(field), 2002))

      op = [{unquote(field), :eq, 1111}]

      results =
        unquote(table)
        |> unquote(domain).filter_by(op)
        |> unquote(domain).repo().all()
        |> Enum.map(fn result -> Map.get(result, unquote(field)) end)

      assert results == [1111]

      unquote(domain).repo().delete(r1)
      unquote(domain).repo().delete(r2)
      unquote(domain).repo().delete(r3)

      ######################################
      # NE
      ######################################
      r1 = insert(unquote(model), Map.put(unquote(params), unquote(field), 1001))
      r2 = insert(unquote(model), Map.put(unquote(params), unquote(field), 1111))
      r3 = insert(unquote(model), Map.put(unquote(params), unquote(field), 2002))

      op = [{unquote(field), :ne, 1111}]

      results =
        unquote(table)
        |> unquote(domain).filter_by(op)
        |> unquote(domain).repo().all()
        |> Enum.map(fn result -> Map.get(result, unquote(field)) end)
        |> Enum.sort_by(fn result -> result end)

      assert results == [1001, 2002]

      unquote(domain).repo().delete(r1)
      unquote(domain).repo().delete(r2)
      unquote(domain).repo().delete(r3)

      ######################################
      # GT
      ######################################
      r1 = insert(unquote(model), Map.put(unquote(params), unquote(field), 1001))
      r2 = insert(unquote(model), Map.put(unquote(params), unquote(field), 1111))
      r3 = insert(unquote(model), Map.put(unquote(params), unquote(field), 2002))

      op = [{unquote(field), :gt, 1111}]

      results =
        unquote(table)
        |> unquote(domain).filter_by(op)
        |> unquote(domain).repo().all()
        |> Enum.map(fn result -> Map.get(result, unquote(field)) end)

      assert results == [2002]

      unquote(domain).repo().delete(r1)
      unquote(domain).repo().delete(r2)
      unquote(domain).repo().delete(r3)

      ######################################
      # GE
      ######################################
      r1 = insert(unquote(model), Map.put(unquote(params), unquote(field), 1001))
      r2 = insert(unquote(model), Map.put(unquote(params), unquote(field), 1111))
      r3 = insert(unquote(model), Map.put(unquote(params), unquote(field), 2002))

      op = [{unquote(field), :ge, 1111}]

      results =
        unquote(table)
        |> unquote(domain).filter_by(op)
        |> unquote(domain).repo().all()
        |> Enum.map(fn result -> Map.get(result, unquote(field)) end)

      assert Enum.sort(results) == [1111, 2002]

      unquote(domain).repo().delete(r1)
      unquote(domain).repo().delete(r2)
      unquote(domain).repo().delete(r3)

      ######################################
      # LT
      ######################################
      r1 = insert(unquote(model), Map.put(unquote(params), unquote(field), 1001))
      r2 = insert(unquote(model), Map.put(unquote(params), unquote(field), 1111))
      r3 = insert(unquote(model), Map.put(unquote(params), unquote(field), 2002))

      op = [{unquote(field), :lt, 1111}]

      results =
        unquote(table)
        |> unquote(domain).filter_by(op)
        |> unquote(domain).repo().all()
        |> Enum.map(fn result -> Map.get(result, unquote(field)) end)

      assert results == [1001]

      unquote(domain).repo().delete(r1)
      unquote(domain).repo().delete(r2)
      unquote(domain).repo().delete(r3)

      ######################################
      # LE
      ######################################
      r1 = insert(unquote(model), Map.put(unquote(params), unquote(field), 1001))
      r2 = insert(unquote(model), Map.put(unquote(params), unquote(field), 1111))
      r3 = insert(unquote(model), Map.put(unquote(params), unquote(field), 2002))

      op = [{unquote(field), :le, 1111}]

      results =
        unquote(table)
        |> unquote(domain).filter_by(op)
        |> unquote(domain).repo().all()
        |> Enum.map(fn result -> Map.get(result, unquote(field)) end)

      assert Enum.sort(results) == [1001, 1111]

      unquote(domain).repo().delete(r1)
      unquote(domain).repo().delete(r2)
      unquote(domain).repo().delete(r3)

      ######################################
      # LIKE
      ######################################
      assert_raise ArgumentError, ~r/Invalid operation/, fn ->
        op = [{unquote(field), :lk, 1111}]

        unquote(domain).filter_by(unquote(table), op)
      end

      ######################################
      # IN
      ######################################
      r1 = insert(unquote(model), Map.put(unquote(params), unquote(field), 1001))
      r2 = insert(unquote(model), Map.put(unquote(params), unquote(field), 1111))

      op = [{unquote(field), :in, [1001, 2002]}]

      results =
        unquote(table)
        |> unquote(domain).filter_by(op)
        |> unquote(domain).repo().all()
        |> Enum.map(fn result -> Map.get(result, unquote(field)) end)

      assert Enum.sort(results) == [1001]

      unquote(domain).repo().delete(r1)
      unquote(domain).repo().delete(r2)

      ######################################
      # NI
      ######################################
      r1 = insert(unquote(model), Map.put(unquote(params), unquote(field), 1001))
      r2 = insert(unquote(model), Map.put(unquote(params), unquote(field), 1111))

      op = [{unquote(field), :ni, [1001, 2002]}]

      results =
        unquote(table)
        |> unquote(domain).filter_by(op)
        |> unquote(domain).repo().all()
        |> Enum.map(fn result -> Map.get(result, unquote(field)) end)

      assert Enum.sort(results) == [1111]

      unquote(domain).repo().delete(r1)
      unquote(domain).repo().delete(r2)
    end
  end
end
