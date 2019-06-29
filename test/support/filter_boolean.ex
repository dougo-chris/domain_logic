defmodule Linklab.DomainLogic.Test.FilterBoolean do
  @moduledoc false

  defmacro test_filter_by_boolean(domain, table, model, field) do
    quote do
      test_filter_by_boolean(unquote(domain), unquote(table), unquote(model), unquote(field), %{})
    end
  end

  defmacro test_filter_by_boolean(domain, table, model, field, params) do
    # credo:disable-for-next-line Credo.Check.Refactor.LongQuoteBlocks
    quote do
      fields = unquote(domain).filter_fields()
      {_, field_type, _} = Enum.find(fields, fn {name, _, _} -> name == unquote(field) end)
      assert field_type == :boolean

      ######################################
      # INVALID OP
      ######################################
      assert_raise ArgumentError, ~r/Invalid operation/, fn ->
        op = [{unquote(field), :invalid, 1111}]

        unquote(domain).filter_by(unquote(table), op)
      end

      ######################################
      # NOT A BOOLEAN
      ######################################
      assert_raise ArgumentError, ~r/Invalid value for boolean/, fn ->
        op = [{unquote(field), :eq, "error value"}]

        unquote(domain).filter_by(unquote(table), op)
      end

      ######################################
      # CONVERT TO BOOLEAN  : yes
      ######################################
      r1 = insert(unquote(model), Map.put(unquote(params), unquote(field), false))
      r2 = insert(unquote(model), Map.put(unquote(params), unquote(field), true))
      r3 = insert(unquote(model), Map.put(unquote(params), unquote(field), false))

      op = [{unquote(field), :eq, "yes"}]

      results =
        unquote(table)
        |> unquote(domain).filter_by(op)
        |> unquote(domain).repo().all()
        |> Enum.map(fn result -> Map.get(result, unquote(field)) end)

      assert results == [true]

      unquote(domain).repo().delete(r1)
      unquote(domain).repo().delete(r2)
      unquote(domain).repo().delete(r3)

      ######################################
      # CONVERT TO BOOLEAN  : true
      ######################################
      r1 = insert(unquote(model), Map.put(unquote(params), unquote(field), false))
      r2 = insert(unquote(model), Map.put(unquote(params), unquote(field), true))
      r3 = insert(unquote(model), Map.put(unquote(params), unquote(field), false))

      op = [{unquote(field), :eq, "true"}]

      results =
        unquote(table)
        |> unquote(domain).filter_by(op)
        |> unquote(domain).repo().all()
        |> Enum.map(fn result -> Map.get(result, unquote(field)) end)

      assert results == [true]

      unquote(domain).repo().delete(r1)
      unquote(domain).repo().delete(r2)
      unquote(domain).repo().delete(r3)

      ######################################
      # CONVERT TO BOOLEAN  : 1
      ######################################
      r1 = insert(unquote(model), Map.put(unquote(params), unquote(field), false))
      r2 = insert(unquote(model), Map.put(unquote(params), unquote(field), true))
      r3 = insert(unquote(model), Map.put(unquote(params), unquote(field), false))

      op = [{unquote(field), :eq, 1}]

      results =
        unquote(table)
        |> unquote(domain).filter_by(op)
        |> unquote(domain).repo().all()
        |> Enum.map(fn result -> Map.get(result, unquote(field)) end)

      assert results == [true]

      unquote(domain).repo().delete(r1)
      unquote(domain).repo().delete(r2)
      unquote(domain).repo().delete(r3)

      ######################################
      # CONVERT TO BOOLEAN  : no
      ######################################
      r1 = insert(unquote(model), Map.put(unquote(params), unquote(field), true))
      r2 = insert(unquote(model), Map.put(unquote(params), unquote(field), false))
      r3 = insert(unquote(model), Map.put(unquote(params), unquote(field), true))

      op = [{unquote(field), :eq, "no"}]

      results =
        unquote(table)
        |> unquote(domain).filter_by(op)
        |> unquote(domain).repo().all()
        |> Enum.map(fn result -> Map.get(result, unquote(field)) end)

      assert results == [false]

      unquote(domain).repo().delete(r1)
      unquote(domain).repo().delete(r2)
      unquote(domain).repo().delete(r3)

      ######################################
      # CONVERT TO BOOLEAN  : false
      ######################################
      r1 = insert(unquote(model), Map.put(unquote(params), unquote(field), true))
      r2 = insert(unquote(model), Map.put(unquote(params), unquote(field), false))
      r3 = insert(unquote(model), Map.put(unquote(params), unquote(field), true))

      op = [{unquote(field), :eq, "false"}]

      results =
        unquote(table)
        |> unquote(domain).filter_by(op)
        |> unquote(domain).repo().all()
        |> Enum.map(fn result -> Map.get(result, unquote(field)) end)

      assert results == [false]

      unquote(domain).repo().delete(r1)
      unquote(domain).repo().delete(r2)
      unquote(domain).repo().delete(r3)

      ######################################
      # CONVERT TO BOOLEAN  : 0
      ######################################
      r1 = insert(unquote(model), Map.put(unquote(params), unquote(field), true))
      r2 = insert(unquote(model), Map.put(unquote(params), unquote(field), false))
      r3 = insert(unquote(model), Map.put(unquote(params), unquote(field), true))

      op = [{unquote(field), :eq, 0}]

      results =
        unquote(table)
        |> unquote(domain).filter_by(op)
        |> unquote(domain).repo().all()
        |> Enum.map(fn result -> Map.get(result, unquote(field)) end)

      assert results == [false]

      unquote(domain).repo().delete(r1)
      unquote(domain).repo().delete(r2)
      unquote(domain).repo().delete(r3)

      ######################################
      # EQ
      ######################################
      r1 = insert(unquote(model), Map.put(unquote(params), unquote(field), false))
      r2 = insert(unquote(model), Map.put(unquote(params), unquote(field), true))
      r3 = insert(unquote(model), Map.put(unquote(params), unquote(field), false))

      op = [{unquote(field), :eq, true}]

      results =
        unquote(table)
        |> unquote(domain).filter_by(op)
        |> unquote(domain).repo().all()
        |> Enum.map(fn result -> Map.get(result, unquote(field)) end)

      assert results == [true]

      unquote(domain).repo().delete(r1)
      unquote(domain).repo().delete(r2)
      unquote(domain).repo().delete(r3)

      ######################################
      # NE
      ######################################
      r1 = insert(unquote(model), Map.put(unquote(params), unquote(field), false))
      r2 = insert(unquote(model), Map.put(unquote(params), unquote(field), true))
      r3 = insert(unquote(model), Map.put(unquote(params), unquote(field), false))

      op = [{unquote(field), :ne, true}]

      results =
        unquote(table)
        |> unquote(domain).filter_by(op)
        |> unquote(domain).repo().all()
        |> Enum.map(fn result -> Map.get(result, unquote(field)) end)

      assert results == [false, false]

      unquote(domain).repo().delete(r1)
      unquote(domain).repo().delete(r2)
      unquote(domain).repo().delete(r3)

      ######################################
      # GT
      ######################################
      assert_raise ArgumentError, ~r/Invalid operation/, fn ->
        op = [{unquote(field), :gt, true}]

        unquote(domain).filter_by(unquote(table), op)
      end

      ######################################
      # GE
      ######################################
      assert_raise ArgumentError, ~r/Invalid operation/, fn ->
        op = [{unquote(field), :ge, true}]

        unquote(domain).filter_by(unquote(table), op)
      end

      ######################################
      # LT
      ######################################
      assert_raise ArgumentError, ~r/Invalid operation/, fn ->
        op = [{unquote(field), :lt, true}]

        unquote(domain).filter_by(unquote(table), op)
      end

      ######################################
      # LE
      ######################################
      assert_raise ArgumentError, ~r/Invalid operation/, fn ->
        op = [{unquote(field), :le, true}]

        unquote(domain).filter_by(unquote(table), op)
      end

      ######################################
      # LIKE
      ######################################
      assert_raise ArgumentError, ~r/Invalid operation/, fn ->
        op = [{unquote(field), :lk, true}]

        unquote(domain).filter_by(unquote(table), op)
      end

      ######################################
      # IN
      ######################################
      assert_raise ArgumentError, ~r/Invalid operation/, fn ->
        op = [{unquote(field), :in, true}]

        unquote(domain).filter_by(unquote(table), op)
      end

      ######################################
      # NI
      ######################################
      assert_raise ArgumentError, ~r/Invalid operation/, fn ->
        op = [{unquote(field), :ni, true}]

        unquote(domain).filter_by(unquote(table), op)
      end
    end
  end
end
