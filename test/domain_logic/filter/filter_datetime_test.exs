defmodule Linklab.DomainLogic.Filter.FilterDatetimeTest do
  use ExUnit.Case

  alias Linklab.DomainLogic.Filter.FilterDatetime

  test "invalid operation" do
    [:lk, :in]
    |> Enum.each(fn operation ->
      assert FilterDatetime.validate_value("2002:12:01", operation) == {:error, "Invalid operation : #{operation}"}
    end)
  end

  test "nil value" do
    assert FilterDatetime.validate_value(nil, :gt) == {:ok, nil}
  end

  describe "validate_value : string" do
    test "valid string" do
      expected = %{year: 2002, month: 12, day: 1, hour: 12, minute: 24, second: 01}
      assert FilterDatetime.validate_value("2002:12:01 12:24:01", :gt) == {:ok, expected}
    end

    test "invalid string" do
      assert FilterDatetime.validate_value("WRONG", :gt) == {:error, "Invalid value for datetime"}
    end
  end

  describe "validate_value : timestamp" do
    test "valid unix timestamp" do
      expected = %{year: 2017, month: 2, day: 2, hour: 11, minute: 42, second: 46}
      assert FilterDatetime.validate_value(1_486_035_766, :gt) == {:ok, expected}
    end

    test "invalid unix timestamp" do
      assert FilterDatetime.validate_value(999_999_999_999, :gt) == {:error, "Invalid value for datetime"}
    end
  end

  describe "validate_value : map" do
    test "valid map" do
      map = %{year: 2002, month: 12, day: 1, hour: 13, minute: 32, second: 35}
      expected = %{year: 2002, month: 12, day: 1, hour: 13, minute: 32, second: 35}
      assert FilterDatetime.validate_value(map, :gt) == {:ok, expected}
    end

    test "invalid map" do
      map = %{}
      assert FilterDatetime.validate_value(map, :gt) == {:error, "Invalid value for datetime"}
    end
  end

  describe "validate_value : tupple" do
    test "valid tupple" do
      tupple = {2002, 12, 1, 13, 32, 35}
      expected = %{year: 2002, month: 12, day: 1, hour: 13, minute: 32, second: 35}
      assert FilterDatetime.validate_value(tupple, :gt) == {:ok, expected}
    end

    test "invalid tupple" do
      tupple = {2002, 12, 1}
      assert FilterDatetime.validate_value(tupple, :gt) == {:error, "Invalid value for datetime"}
    end
  end

  describe "validate_value : Date" do
    test "valid date" do
      date =
        1_486_035_311
        |> DateTime.from_unix!()
        |> DateTime.to_date()

      expected = %{year: 2017, month: 2, day: 2, hour: 0, minute: 0, second: 0}
      assert FilterDatetime.validate_value(date, :gt) == {:ok, expected}
    end
  end

  describe "validate_value : DateTime" do
    test "valid datetime" do
      date_time = DateTime.from_unix!(1_486_035_311)
      expected = %{year: 2017, month: 2, day: 2, hour: 11, minute: 35, second: 11}
      assert FilterDatetime.validate_value(date_time, :gt) == {:ok, expected}
    end
  end

  describe "validate_value : NaiveDateTime" do
    test "valid datetime" do
      ndt =
        1_486_035_311
        |> DateTime.from_unix!()
        |> DateTime.to_naive()

      expected = %{year: 2017, month: 2, day: 2, hour: 11, minute: 35, second: 11}
      assert FilterDatetime.validate_value(ndt, :gt) == {:ok, expected}
    end
  end
end
