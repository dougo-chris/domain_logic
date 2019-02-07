defmodule Linklab.DomainLogic.Filter.FilterInteger do
  @moduledoc false

  def validate_value(_value, op) when op in [:lk] do
    {:error, "Invalid operation : #{op}"}
  end

  def validate_value(nil, :in), do: {:ok, [nil]}
  def validate_value(nil, _op), do: {:ok, nil}

  def validate_value(value, :in) when is_integer(value) do
    {:ok, [value]}
  end

  def validate_value(value, :in) when is_binary(value) do
    case Integer.parse(value) do
      :error ->
        {:error, "Invalid integer"}

      {value, _} ->
        {:ok, [value]}
    end
  end

  def validate_value(value, :in) when is_list(value) do
    values =
      value
      |> Enum.map(fn
        value when value == nil ->
          {:ok, nil}
        value when is_integer(value) ->
          {:ok, value}
        value when is_binary(value) ->
          case Integer.parse(value) do
            :error ->
              {:error, "Invalid integer"}

            {value, _} ->
              {:ok, value}
          end

        _ ->
          {:error, "Invalid integer"}
      end)

    if Enum.find(values, fn {result, _} -> result == :error end) do
      {:error, "Invalid integer"}
    else
      {:ok, Enum.map(values, fn {_, value} -> value end)}
    end
  end

  def validate_value(value, _op) when is_integer(value) do
    {:ok, value}
  end

  def validate_value(value, _op) when is_binary(value) do
    case Integer.parse(value) do
      :error ->
        {:error, "Invalid integer"}

      {value, _} ->
        {:ok, value}
    end
  end

  def validate_value(_value, _op) do
    {:error, "Invalid integer"}
  end
end
