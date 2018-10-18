defmodule Linklab.DomainLogic.Filter.FilterString do
  @moduledoc false

  def validate_value(value, :in) when is_binary(value) do
    {:ok, [value]}
  end

  def validate_value(value, :in) when is_integer(value) do
    {:ok, Integer.to_string(value)}
  end

  def validate_value(value, :in) when is_list(value) do
    values =
      value
      |> Enum.map(fn
        value when is_binary(value) -> value
        value when is_integer(value) -> Integer.to_string(value)
        _ -> nil
      end)

    if Enum.find(values, &is_nil/1) do
      {:error, "Invalid string"}
    else
      {:ok, values}
    end
  end

  def validate_value(value, _op) when is_binary(value) do
    {:ok, value}
  end

  def validate_value(value, _op) when is_integer(value) do
    {:ok, Integer.to_string(value)}
  end

  def validate_value(_value, _op) do
    {:error, "Invalid string"}
  end
end
