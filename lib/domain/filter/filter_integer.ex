defmodule DomainLogic.Domain.Filter.FilterInteger do
  @moduledoc false

  def validate_value(_value, op) when op in [:lk] do
    {:error, "Invalid operation : #{op}"}
  end

  def validate_value(nil, op) when op in [:ne, :eq] do
    {:ok, nil}
  end

  def validate_value(nil, op) do
    {:error, "Invalid operation for nil integer : #{op}"}
  end

  def validate_value(value, op) when op in [:in, :ni] and is_list(value) do
    values =
      value
      |> Enum.map(fn
        nil ->
          {:error, "Invalid value for integer"}

        value when is_integer(value) ->
          {:ok, value}

        value when is_binary(value) ->
          case Integer.parse(value) do
            :error ->
              {:error, "Invalid value for integer"}

            {value, _} ->
              {:ok, value}
          end

        _ ->
          {:error, "Invalid value for integer"}
      end)

    if Enum.find(values, fn {result, _} -> result == :error end) do
      {:error, "Invalid value for integer"}
    else
      {:ok, Enum.map(values, fn {_, value} -> value end)}
    end
  end

  def validate_value(_value, op) when op in [:in, :ni] do
    {:error, "Invalid value for integer : #{op}"}
  end

  def validate_value(value, _op) when is_integer(value) do
    {:ok, value}
  end

  def validate_value(value, _op) when is_binary(value) do
    case Integer.parse(value) do
      :error ->
        {:error, "Invalid value for integer"}

      {value, _} ->
        {:ok, value}
    end
  end

  def validate_value(_value, _op) do
    {:error, "Invalid value for integer"}
  end
end
