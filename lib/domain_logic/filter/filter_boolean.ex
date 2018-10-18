defmodule Linklab.DomainLogic.Filter.FilterBoolean do
  @moduledoc false

  def validate_value(value, :eq) do
    cond do
      is_boolean(value) -> {:ok, value}
      is_binary(value) && String.match?(value, ~r/true/i) -> {:ok, true}
      is_binary(value) && String.match?(value, ~r/false/i) -> {:ok, false}
      is_binary(value) && String.match?(value, ~r/yes/i) -> {:ok, true}
      is_binary(value) && String.match?(value, ~r/no/i) -> {:ok, false}
      is_integer(value) && value == 1 -> {:ok, true}
      is_integer(value) && value == 0 -> {:ok, false}
      true -> {:error, "Invalid boolean"}
    end
  end

  def validate_value(_value, _op) do
    {:error, "Invalid boolean"}
  end
end
