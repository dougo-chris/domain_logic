defmodule Linklab.DomainLogic.Test.FilterString do
  @moduledoc false

  defmacro test_filter_by_string(domain, table, model, field) do
    quote do
      test_filter_by_string(unquote(domain), unquote(table), unquote(model), unquote(field), %{})
    end
  end

  defmacro test_filter_by_string(domain, table, model, field, params) do
    # credo:disable-for-next-line Credo.Check.Refactor.LongQuoteBlocks
    quote do
      field_type = unquote(domain).filter_fields()[unquote(field)]
      assert field_type == :string

      ######################################
      # INVALID OP
      ######################################
      assert_raise ArgumentError, ~r/Invalid operation/, fn ->
        op = [{unquote(field), :invalid, "VALUE"}]

        unquote(domain).filter_by(unquote(table), op)
      end

      ######################################
      # NOT A STRING
      ######################################
      assert_raise ArgumentError, ~r/Invalid value/, fn ->
        op = [{unquote(field), :eq, ~r/WHY/}]

        unquote(domain).filter_by(unquote(table), op)
      end

      ######################################
      # CONVERT TO STRING
      ######################################
      r1 = insert(unquote(model), Map.put(unquote(params), unquote(field), "1001"))
      r2 = insert(unquote(model), Map.put(unquote(params), unquote(field), "1111"))
      r3 = insert(unquote(model), Map.put(unquote(params), unquote(field), "2002"))

      op = [{unquote(field), :eq, 2002}]

      results =
        unquote(table)
        |> unquote(domain).filter_by(op)
        |> unquote(domain).repo().all()
        |> Enum.map(fn result -> Map.get(result, unquote(field)) end)

      assert results == ["2002"]

      unquote(domain).repo().delete(r1)
      unquote(domain).repo().delete(r2)
      unquote(domain).repo().delete(r3)

      ######################################
      # EQ
      ######################################
      r1 = insert(unquote(model), Map.put(unquote(params), unquote(field), "AVALUE"))
      r2 = insert(unquote(model), Map.put(unquote(params), unquote(field), "VALUE"))
      r3 = insert(unquote(model), Map.put(unquote(params), unquote(field), "VALUEZ"))

      op = [{unquote(field), :eq, "VALUE"}]

      results =
        unquote(table)
        |> unquote(domain).filter_by(op)
        |> unquote(domain).repo().all()
        |> Enum.map(fn result -> Map.get(result, unquote(field)) end)

      assert results == ["VALUE"]

      unquote(domain).repo().delete(r1)
      unquote(domain).repo().delete(r2)
      unquote(domain).repo().delete(r3)

      ######################################
      # NE
      ######################################
      r1 = insert(unquote(model), Map.put(unquote(params), unquote(field), "AVALUE"))
      r2 = insert(unquote(model), Map.put(unquote(params), unquote(field), "VALUE"))
      r3 = insert(unquote(model), Map.put(unquote(params), unquote(field), "VALUEZ"))

      op = [{unquote(field), :ne, "VALUE"}]

      results =
        unquote(table)
        |> unquote(domain).filter_by(op)
        |> unquote(domain).repo().all()
        |> Enum.map(fn result -> Map.get(result, unquote(field)) end)
        |> Enum.sort_by(fn result -> result end)

      assert results == ["AVALUE", "VALUEZ"]

      unquote(domain).repo().delete(r1)
      unquote(domain).repo().delete(r2)
      unquote(domain).repo().delete(r3)

      ######################################
      # GT
      ######################################
      r1 = insert(unquote(model), Map.put(unquote(params), unquote(field), "AVALUE"))
      r2 = insert(unquote(model), Map.put(unquote(params), unquote(field), "VALUE"))
      r3 = insert(unquote(model), Map.put(unquote(params), unquote(field), "VALUEZ"))

      op = [{unquote(field), :gt, "VALUE"}]

      results =
        unquote(table)
        |> unquote(domain).filter_by(op)
        |> unquote(domain).repo().all()
        |> Enum.map(fn result -> Map.get(result, unquote(field)) end)

      assert results == ["VALUEZ"]

      unquote(domain).repo().delete(r1)
      unquote(domain).repo().delete(r2)
      unquote(domain).repo().delete(r3)

      ######################################
      # GE
      ######################################
      r1 = insert(unquote(model), Map.put(unquote(params), unquote(field), "AVALUE"))
      r2 = insert(unquote(model), Map.put(unquote(params), unquote(field), "VALUE"))
      r3 = insert(unquote(model), Map.put(unquote(params), unquote(field), "VALUEZ"))

      op = [{unquote(field), :ge, "VALUE"}]

      results =
        unquote(table)
        |> unquote(domain).filter_by(op)
        |> unquote(domain).repo().all()
        |> Enum.map(fn result -> Map.get(result, unquote(field)) end)

      assert Enum.sort(results) == ["VALUE", "VALUEZ"]

      unquote(domain).repo().delete(r1)
      unquote(domain).repo().delete(r2)
      unquote(domain).repo().delete(r3)

      ######################################
      # LT
      ######################################
      r1 = insert(unquote(model), Map.put(unquote(params), unquote(field), "AVALUE"))
      r2 = insert(unquote(model), Map.put(unquote(params), unquote(field), "VALUE"))
      r3 = insert(unquote(model), Map.put(unquote(params), unquote(field), "VALUEZ"))

      op = [{unquote(field), :lt, "VALUE"}]

      results =
        unquote(table)
        |> unquote(domain).filter_by(op)
        |> unquote(domain).repo().all()
        |> Enum.map(fn result -> Map.get(result, unquote(field)) end)

      assert results == ["AVALUE"]

      unquote(domain).repo().delete(r1)
      unquote(domain).repo().delete(r2)
      unquote(domain).repo().delete(r3)

      ######################################
      # LE
      ######################################
      r1 = insert(unquote(model), Map.put(unquote(params), unquote(field), "AVALUE"))
      r2 = insert(unquote(model), Map.put(unquote(params), unquote(field), "VALUE"))
      r3 = insert(unquote(model), Map.put(unquote(params), unquote(field), "VALUEZ"))

      op = [{unquote(field), :le, "VALUE"}]

      results =
        unquote(table)
        |> unquote(domain).filter_by(op)
        |> unquote(domain).repo().all()
        |> Enum.map(fn result -> Map.get(result, unquote(field)) end)

      assert Enum.sort(results) == ["AVALUE", "VALUE"]

      unquote(domain).repo().delete(r1)
      unquote(domain).repo().delete(r2)
      unquote(domain).repo().delete(r3)

      ######################################
      # LIKE
      ######################################
      r1 = insert(unquote(model), Map.put(unquote(params), unquote(field), "NOT ME"))
      r2 = insert(unquote(model), Map.put(unquote(params), unquote(field), "AVALUE"))
      r3 = insert(unquote(model), Map.put(unquote(params), unquote(field), "VALUE"))
      r4 = insert(unquote(model), Map.put(unquote(params), unquote(field), "VALUEZ"))
      r5 = insert(unquote(model), Map.put(unquote(params), unquote(field), "OR ME"))

      op = [{unquote(field), :lk, "VALUE"}]

      results =
        unquote(table)
        |> unquote(domain).filter_by(op)
        |> unquote(domain).repo().all()
        |> Enum.map(fn result -> Map.get(result, unquote(field)) end)

      assert Enum.sort(results) == ["AVALUE", "VALUE", "VALUEZ"]

      unquote(domain).repo().delete(r1)
      unquote(domain).repo().delete(r2)
      unquote(domain).repo().delete(r3)
      unquote(domain).repo().delete(r4)
      unquote(domain).repo().delete(r5)

      ######################################
      # IN
      ######################################
      r1 = insert(unquote(model), Map.put(unquote(params), unquote(field), "FIND ME"))
      r2 = insert(unquote(model), Map.put(unquote(params), unquote(field), "VALUE"))

      op = [{unquote(field), :in, ["FIND ME", "AND ME"]}]

      results =
        unquote(table)
        |> unquote(domain).filter_by(op)
        |> unquote(domain).repo().all()
        |> Enum.map(fn result -> Map.get(result, unquote(field)) end)

      assert Enum.sort(results) == ["FIND ME"]

      unquote(domain).repo().delete(r1)
      unquote(domain).repo().delete(r2)

      ######################################
      # NI
      ######################################
      r1 = insert(unquote(model), Map.put(unquote(params), unquote(field), "FIND ME"))
      r2 = insert(unquote(model), Map.put(unquote(params), unquote(field), "VALUE"))

      op = [{unquote(field), :ni, ["FIND ME", "AND ME"]}]

      results =
        unquote(table)
        |> unquote(domain).filter_by(op)
        |> unquote(domain).repo().all()
        |> Enum.map(fn result -> Map.get(result, unquote(field)) end)

      assert Enum.sort(results) == ["VALUE"]

      unquote(domain).repo().delete(r1)
      unquote(domain).repo().delete(r2)
    end
  end
end
