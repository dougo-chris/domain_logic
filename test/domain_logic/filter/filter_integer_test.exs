defmodule Linklab.DomainLogic.Filter.FilterIntegerTest do
  use ExUnit.Case

  alias Linklab.DomainLogic.Filter.FilterInteger

  test "invalid operation" do
    [:lk]
    |> Enum.each(fn operation ->
      result = FilterInteger.validate_value(1001, operation)
      assert result == {:error, "Invalid operation : #{operation}"}
    end)
  end

  test "nil value" do
    assert FilterInteger.validate_value(nil, :gt) == {:ok, nil}
  end

  test "nil :in" do
    assert FilterInteger.validate_value(nil, :in) == {:ok, [nil]}
  end

  test "nil :ni" do
    assert FilterInteger.validate_value(nil, :in) == {:ok, [nil]}
  end

  describe "validate_value : integer" do
    test "valid integer" do
      assert FilterInteger.validate_value(1111, :gt) == {:ok, 1111}
    end

    test "in value" do
      assert FilterInteger.validate_value(1111, :in) == {:ok, [1111]}
    end

    test "in list" do
      assert FilterInteger.validate_value([1111, 2222], :in) == {:ok, [1111, 2222]}
    end

    test "in invalid list" do
      assert FilterInteger.validate_value([1111, nil], :in) == {:ok, [1111, nil]}
    end

    test "ni value" do
      assert FilterInteger.validate_value(1111, :ni) == {:ok, [1111]}
    end

    test "ni list" do
      assert FilterInteger.validate_value([1111, 2222], :ni) == {:ok, [1111, 2222]}
    end

    test "ni invalid list" do
      assert FilterInteger.validate_value([1111, nil], :ni) == {:ok, [1111, nil]}
    end
  end

  describe "validate_value : string" do
    test "valid integer" do
      assert FilterInteger.validate_value("1111", :gt) == {:ok, 1111}
    end

    test "invalid integer" do
      assert FilterInteger.validate_value("WRONG", :gt) == {:error, "Invalid value for integer"}
    end

    test "in value" do
      assert FilterInteger.validate_value("1111", :in) == {:ok, [1111]}
    end

    test "in list" do
      assert FilterInteger.validate_value(["1111", 2222], :in) == {:ok, [1111, 2222]}
    end

    test "in invalid list" do
      assert FilterInteger.validate_value(["1111", nil], :in) == {:ok, [1111, nil]}
    end

    test "ni value" do
      assert FilterInteger.validate_value("1111", :ni) == {:ok, [1111]}
    end

    test "ni list" do
      assert FilterInteger.validate_value(["1111", 2222], :ni) == {:ok, [1111, 2222]}
    end

    test "ni invalid list" do
      assert FilterInteger.validate_value(["1111", nil], :ni) == {:ok, [1111, nil]}
    end
  end
end
