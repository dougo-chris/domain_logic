defmodule Linklab.DomainLogic.Filter.FilterBoolean do
  @moduledoc false

  def validate_value(_value, op) when op not in [:ne, :eq] do
    {:error, "Invalid operation : #{op}"}
  end

  def validate_value(nil, _op), do: {:ok, nil}

  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  def validate_value(value, _op) do
    cond do
      is_boolean(value) -> {:ok, value}
      is_binary(value) && value == "true" -> {:ok, true}
      is_binary(value) && value == "false" -> {:ok, false}
      is_binary(value) && value == "yes" -> {:ok, true}
      is_binary(value) && value == "no" -> {:ok, false}
      is_integer(value) && value == 1 -> {:ok, true}
      is_integer(value) && value == 0 -> {:ok, false}
      true -> {:error, "Invalid value for boolean"}
    end
  end
end
