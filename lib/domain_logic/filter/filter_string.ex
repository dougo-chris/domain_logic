defmodule Linklab.DomainLogic.Filter.FilterString do
  @moduledoc false

  def validate_value(nil, :in), do: {:ok, [nil]}
  def validate_value(nil, _op), do: {:ok, nil}

  def validate_value(value, :in) when is_binary(value) do
    {:ok, [value]}
  end

  def validate_value(value, :in) when is_integer(value) do
    {:ok, [Integer.to_string(value)]}
  end

  def validate_value(value, :in) when is_list(value) do
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
          {:error, "Invalid string"}
      end)

    if Enum.find(values, fn {result, _} -> result == :error end) do
      {:error, "Invalid string"}
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
    {:error, "Invalid string"}
  end
end
