defmodule DomainLogic.Domain.Filter.FilterStringTest do
  use ExUnit.Case

  alias DomainLogic.Domain.Filter.FilterString

  test "nil value for eq" do
    assert FilterString.validate_value(nil, :eq) == {:ok, nil}
  end

  test "nil value for ne" do
    assert FilterString.validate_value(nil, :ne) == {:ok, nil}
  end

  test "nil value" do
    assert FilterString.validate_value(nil, :gt) == {:error, "Invalid operation for nil string"}
  end

  test "invalid value" do
    assert FilterString.validate_value(~r/WRONG/, :gt) == {:error, "Invalid value for string"}
  end

  test "invalid in" do
    assert FilterString.validate_value([~r/WRONG/], :in) == {:error, "Invalid value for string"}
  end

  test "invalid ni" do
    assert FilterString.validate_value([~r/WRONG/], :ni) == {:error, "Invalid value for string"}
  end

  describe "validate_value : string" do
    test "valid integer" do
      assert FilterString.validate_value("1111", :gt) == {:ok, "1111"}
    end

    test "in value" do
      assert FilterString.validate_value("1111", :in) == {:ok, ["1111"]}
    end

    test "in list" do
      assert FilterString.validate_value(["1111", "2222"], :in) == {:ok, ["1111", "2222"]}
    end

    test "in empty" do
      assert FilterString.validate_value([], :in) == {:ok, []}
    end

    test "in invalid list" do
      assert FilterString.validate_value(["1111", nil], :in) == {:ok, ["1111", nil]}
    end

    test "ni value" do
      assert FilterString.validate_value("1111", :ni) == {:ok, ["1111"]}
    end

    test "ni list" do
      assert FilterString.validate_value(["1111", "2222"], :ni) == {:ok, ["1111", "2222"]}
    end

    test "ni empty" do
      assert FilterString.validate_value([], :ni) == {:ok, []}
    end

    test "ni invalid list" do
      assert FilterString.validate_value(["1111", nil], :ni) == {:ok, ["1111", nil]}
    end
  end

  describe "validate_value : integer" do
    test "valid integer" do
      assert FilterString.validate_value(1111, :gt) == {:ok, "1111"}
    end

    test "in value" do
      assert FilterString.validate_value(1111, :in) == {:ok, ["1111"]}
    end

    test "in list" do
      assert FilterString.validate_value([1111, "2222"], :in) == {:ok, ["1111", "2222"]}
    end

    test "in invalid list" do
      assert FilterString.validate_value([1111, nil], :in) == {:ok, ["1111", nil]}
    end

    test "ni value" do
      assert FilterString.validate_value(1111, :ni) == {:ok, ["1111"]}
    end

    test "ni list" do
      assert FilterString.validate_value([1111, "2222"], :ni) == {:ok, ["1111", "2222"]}
    end

    test "ni invalid list" do
      assert FilterString.validate_value([1111, nil], :ni) == {:ok, ["1111", nil]}
    end
  end
end
