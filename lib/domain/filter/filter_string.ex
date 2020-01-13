defmodule DomainLogic.Domain.Filter.FilterString do
  @moduledoc false

  def validate_value(nil, op) when op in [:ne, :eq] do
    {:ok, nil}
  end

  def validate_value(nil, _op) do
    {:error, "Invalid operation for nil string"}
  end

  def validate_value(value, op) when op in [:in, :ni] and is_binary(value) do
    {:ok, [value]}
  end

  def validate_value(value, op) when op in [:in, :ni] and is_integer(value) do
    {:ok, [Integer.to_string(value)]}
  end

  def validate_value(value, op) when op in [:in, :ni] when is_list(value) do
    values =
      value
      |> Enum.map(fn
        value when value == nil ->
          {:ok, nil}

        value when is_binary(value) ->
          {:ok, value}

        value when is_integer(value) ->
          {:ok, Integer.to_string(value)}

        _ ->
          {:error, "Invalid value for string"}
      end)

    if Enum.find(values, fn {result, _} -> result == :error end) do
      {:error, "Invalid value for string"}
    else
      {:ok, Enum.map(values, fn {_, value} -> value end)}
    end
  end

  def validate_value(value, _op) when is_binary(value) do
    {:ok, value}
  end

  def validate_value(value, _op) when is_integer(value) do
    {:ok, Integer.to_string(value)}
  end

  def validate_value(_value, _op) do
    {:error, "Invalid value for string"}
  end
end
