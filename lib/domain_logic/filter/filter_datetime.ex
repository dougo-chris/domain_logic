defmodule Linklab.DomainLogic.Filter.FilterDatetime do
  @moduledoc false

  def validate_value(_value, :eq) do
    {:error, "Invalid operation"}
  end

  def validate_value(_value, :in) do
    {:error, "Invalid operation"}
  end

  def validate_value(value, op) when is_binary(value) do
    with [date, time] <- String.split(value, " "),
        [ys, ms, ds] <- String.split(date, ":"),
        [hs, mms, ss] <- String.split(time, ":"),
        {year, _} <- Integer.parse(ys),
        {month, _} <- Integer.parse(ms),
        {day, _} <- Integer.parse(ds),
        {hour, _} <- Integer.parse(hs),
        {minute, _} <- Integer.parse(mms),
        {second, _} <- Integer.parse(ss) do
      validate_value({year, month, day, hour, minute, second}, op)
    else
      _ ->
        {:error, "Invalid date"}
    end
  end

  def validate_value(value, op) when is_integer(value) do
    case DateTime.from_unix(value) do
      {:ok, datetime} -> validate_value(datetime, op)
      _ -> {:error, "Invalid date"}
    end
  end

  def validate_value(%{year: year, month: month, day: day, hour: hour, minute: minute, second: second}, op) do
    validate_value({year, month, day, hour, minute, second}, op)
  end

  def validate_value(%Date{} = date, op) do
    validate_value({date.year, date.month, date.day, 0, 0, 0}, op)
  end

  def validate_value(%DateTime{} = dt, op) do
    validate_value({dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second}, op)
  end

  def validate_value(%NaiveDateTime{} = ndt, op) do
    validate_value({ndt.year, ndt.month, ndt.day, ndt.hour, ndt.minute, ndt.second}, op)
  end

  def validate_value({year, month, day, hour, minute, second}, op) when op in [:gt, :ge, :lt, :le] do
    {:ok, %{year: year, month: month, day: day, hour: hour, minute: minute, second: second}}
  end

  def validate_value(_value, _op) do
    {:error, "Invalid date"}
  end
end
