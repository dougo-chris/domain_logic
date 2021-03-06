defmodule DomainLogic.Domain.Filter.FilterBooleanTest do
  use ExUnit.Case

  alias DomainLogic.Domain.Filter.FilterBoolean

  test "invalid operation" do
    [:gt, :ge, :lt, :le, :lk, :in, :ni]
    |> Enum.each(fn operation ->
      result = FilterBoolean.validate_value(true, operation)
      assert result == {:error, "Invalid operation : #{operation}"}
    end)
  end

  test "nil value" do
    assert FilterBoolean.validate_value(nil, :eq) == {:ok, nil}
  end

  describe "validate_value" do
    test "valid true value" do
      ["true", "yes", 1, true]
      |> Enum.each(fn value ->
        assert FilterBoolean.validate_value(value, :eq) == {:ok, true}
      end)
    end

    test "valid false value" do
      ["false", "no", 0, false]
      |> Enum.each(fn value ->
        assert FilterBoolean.validate_value(value, :eq) == {:ok, false}
      end)
    end

    test "invalid value" do
      assert FilterBoolean.validate_value("ERROR", :eq) == {:error, "Invalid value for boolean"}
    end
  end
end
