defmodule DomainLogic.Domain.Filter.FilterIntegerTest do
  use ExUnit.Case

  alias DomainLogic.Domain.Filter.FilterInteger

  test "invalid operation" do
    [:lk]
    |> Enum.each(fn operation ->
      result = FilterInteger.validate_value(1001, operation)
      assert result == {:error, "Invalid operation : #{operation}"}
    end)
  end

  test "nil :eq" do
    assert FilterInteger.validate_value(nil, :eq) == {:ok, nil}
  end

  test "nil :ne" do
    assert FilterInteger.validate_value(nil, :ne) == {:ok, nil}
  end

  test "invalid nil operation" do
    assert FilterInteger.validate_value(nil, :gt) == {:error, "Invalid operation for nil integer"}
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

    test "in empty" do
      assert FilterInteger.validate_value([], :in) == {:ok, []}
    end

    test "ni value" do
      assert FilterInteger.validate_value(1111, :ni) == {:ok, [1111]}
    end

    test "ni list" do
      assert FilterInteger.validate_value([1111, 2222], :ni) == {:ok, [1111, 2222]}
    end

    test "ni empty" do
      assert FilterInteger.validate_value([], :ni) == {:ok, []}
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
