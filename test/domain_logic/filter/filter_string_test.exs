defmodule DomainLogic.DomainQuery.Filter.FilterStringTest do
  use ExUnit.Case

  alias DomainLogic.DomainQuery.Filter.FilterString

  test "nil value" do
    assert FilterString.validate_value(nil, :gt) == {:ok, nil}
  end

  test "nil in" do
    assert FilterString.validate_value(nil, :in) == {:ok, [nil]}
  end

  test "nil ni" do
    assert FilterString.validate_value(nil, :ni) == {:ok, [nil]}
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

    test "in invalid list" do
      assert FilterString.validate_value(["1111", nil], :in) == {:ok, ["1111", nil]}
    end

    test "ni value" do
      assert FilterString.validate_value("1111", :ni) == {:ok, ["1111"]}
    end

    test "ni list" do
      assert FilterString.validate_value(["1111", "2222"], :ni) == {:ok, ["1111", "2222"]}
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
