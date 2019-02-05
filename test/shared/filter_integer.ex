defmodule Linklab.DomainLogic.Test.FilterInteger do

  defmacro test_filter_by_integer(domain, table, model, field) do
    quote do
      test_filter_by_integer(unquote(domain), unquote(table), unquote(model), unquote(field), %{})
    end
  end

  defmacro test_filter_by_integer(domain, table, model, field, params) do
    quote do
      field_type = unquote(domain).filter_fields()[unquote(field)]
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
      assert_raise ArgumentError, ~r/Invalid integer/, fn ->
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
        |> Linklab.DomainLogic.Test.Repo.all()
        |> Enum.map(fn result -> Map.get(result, unquote(field)) end)

      assert results == [2002]

      Linklab.DomainLogic.Test.Repo.delete(r1)
      Linklab.DomainLogic.Test.Repo.delete(r2)
      Linklab.DomainLogic.Test.Repo.delete(r3)

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
        |> Linklab.DomainLogic.Test.Repo.all()
        |> Enum.map(fn result -> Map.get(result, unquote(field)) end)

      assert results == [1111]

      Linklab.DomainLogic.Test.Repo.delete(r1)
      Linklab.DomainLogic.Test.Repo.delete(r2)
      Linklab.DomainLogic.Test.Repo.delete(r3)

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
        |> Linklab.DomainLogic.Test.Repo.all()
        |> Enum.map(fn result -> Map.get(result, unquote(field)) end)

      assert results == [1001, 2002]

      Linklab.DomainLogic.Test.Repo.delete(r1)
      Linklab.DomainLogic.Test.Repo.delete(r2)
      Linklab.DomainLogic.Test.Repo.delete(r3)

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
        |> Linklab.DomainLogic.Test.Repo.all()
        |> Enum.map(fn result -> Map.get(result, unquote(field)) end)

      assert results == [2002]

      Linklab.DomainLogic.Test.Repo.delete(r1)
      Linklab.DomainLogic.Test.Repo.delete(r2)
      Linklab.DomainLogic.Test.Repo.delete(r3)

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
        |> Linklab.DomainLogic.Test.Repo.all()
        |> Enum.map(fn result -> Map.get(result, unquote(field)) end)

      assert Enum.sort(results) == [1111, 2002]

      Linklab.DomainLogic.Test.Repo.delete(r1)
      Linklab.DomainLogic.Test.Repo.delete(r2)
      Linklab.DomainLogic.Test.Repo.delete(r3)

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
        |> Linklab.DomainLogic.Test.Repo.all()
        |> Enum.map(fn result -> Map.get(result, unquote(field)) end)

      assert results == [1001]

      Linklab.DomainLogic.Test.Repo.delete(r1)
      Linklab.DomainLogic.Test.Repo.delete(r2)
      Linklab.DomainLogic.Test.Repo.delete(r3)

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
        |> Linklab.DomainLogic.Test.Repo.all()
        |> Enum.map(fn result -> Map.get(result, unquote(field)) end)

      assert Enum.sort(results) == [1001, 1111]

      Linklab.DomainLogic.Test.Repo.delete(r1)
      Linklab.DomainLogic.Test.Repo.delete(r2)
      Linklab.DomainLogic.Test.Repo.delete(r3)

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
        |> Linklab.DomainLogic.Test.Repo.all()
        |> Enum.map(fn result -> Map.get(result, unquote(field)) end)

      assert Enum.sort(results) == [1001]

      Linklab.DomainLogic.Test.Repo.delete(r1)
      Linklab.DomainLogic.Test.Repo.delete(r2)
    end
  end
end