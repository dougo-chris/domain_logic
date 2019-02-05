defmodule Linklab.DomainLogic.Filter.FilterBooleanTest do
  use ExUnit.Case

  alias Linklab.DomainLogic.Filter.FilterBoolean

  describe "validate_value" do
    test "valid true value and operation" do
      ["true", "yes", 1, true]
      |> Enum.each(fn value ->
        assert FilterBoolean.validate_value(value, :eq) == {:ok, true}
      end)
    end

    test "valid false value and operation" do
      ["false", "no", 0, false]
      |> Enum.each(fn value ->
        assert FilterBoolean.validate_value(value, :eq) == {:ok, false}
      end)
    end

    test "invalid value" do
      assert FilterBoolean.validate_value("ERROR", :eq) == {:error, "Invalid boolean"}
    end

    test "invalid operation" do
      [:gt, :ge, :lt, :le, :lk, :in]
      |> Enum.each(fn operation ->
        assert FilterBoolean.validate_value(true, operation) == {:error, "Invalid boolean"}
      end)
    end
  end
end
