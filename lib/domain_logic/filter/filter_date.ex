defmodule DomainLogic.DomainQuery.Filter.FilterDate do
  @moduledoc false

  def validate_value(_value, op) when op not in [:gt, :ge, :lt, :le, :ne, :eq] do
    {:error, "Invalid operation : #{op}"}
  end

  def validate_value(nil, _op), do: {:ok, nil}

  def validate_value(value, op) when is_binary(value) do
    with [ys, ms, ds] <- String.split(value, ":"),
         {year, _} <- Integer.parse(ys),
         {month, _} <- Integer.parse(ms),
         {day, _} <- Integer.parse(ds) do
      validate_value({year, month, day, 0, 0, 0}, op)
    else
      _ ->
        {:error, "Invalid value for date"}
    end
  end

  def validate_value(value, op) when is_integer(value) do
    case DateTime.from_unix(value) do
      {:ok, datetime} -> validate_value(datetime, op)
      _ -> {:error, "Invalid value for date"}
    end
  end

  def validate_value(%{year: year, month: month, day: day}, op) do
    validate_value({year, month, day, 0, 0, 0}, op)
  end

  def validate_value(%Date{} = date, op) do
    validate_value({date.year, date.month, date.day, 0, 0, 0}, op)
  end

  def validate_value(%DateTime{} = dt, op) do
    validate_value({dt.year, dt.month, dt.day, 0, 0, 0}, op)
  end

  def validate_value(%NaiveDateTime{} = ndt, op) do
    validate_value({ndt.year, ndt.month, ndt.day, 0, 0, 0}, op)
  end

  def validate_value({year, month, day, _, _, _}, :gt) do
    {:ok, %{year: year, month: month, day: day, hour: 23, minute: 59, second: 59}}
  end

  def validate_value({year, month, day, _, _, _}, :ge) do
    {:ok, %{year: year, month: month, day: day, hour: 0, minute: 0, second: 0}}
  end

  def validate_value({year, month, day, _, _, _}, :lt) do
    {:ok, %{year: year, month: month, day: day, hour: 0, minute: 0, second: 0}}
  end

  def validate_value({year, month, day, _, _, _}, :le) do
    {:ok, %{year: year, month: month, day: day, hour: 23, minute: 59, second: 59}}
  end

  def validate_value({year, month, day, _, _, _}, _op) do
    {:ok, %{year: year, month: month, day: day, hour: 0, minute: 0, second: 0}}
  end

  def validate_value(_value, _op) do
    {:error, "Invalid value for date"}
  end
end
