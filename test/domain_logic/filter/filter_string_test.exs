defmodule Linklab.DomainLogic.Filter.FilterStringTest do
  use ExUnit.Case

  alias Linklab.DomainLogic.Filter.FilterString

  test "nil value" do
    assert FilterString.validate_value(nil, :gt) == {:ok, nil}
  end

  test "nil in" do
    assert FilterString.validate_value(nil, :in) == {:ok, [nil]}
  end

  test "invalid value" do
    assert FilterString.validate_value(~r/WRONG/, :gt) == {:error, "Invalid string"}
  end

  test "invalid in" do
    assert FilterString.validate_value([~r/WRONG/], :in) == {:error, "Invalid string"}
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

    test "invalid list" do
      assert FilterString.validate_value(["1111", nil], :in) == {:ok, ["1111", nil]}
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

    test "invalid list" do
      assert FilterString.validate_value([1111, nil], :in) == {:ok, ["1111", nil]}
    end
  end
end
