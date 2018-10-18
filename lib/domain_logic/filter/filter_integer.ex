defmodule Linklab.DomainLogic.Filter.FilterInteger do
  @moduledoc false

  def validate_value(value, :in) when is_integer(value) do
    {:ok, [value]}
  end

  def validate_value(value, :in) when is_binary(value) do
    case Integer.parse(value) do
      :error -> {:error, "Invalid integer"}
      {value, _} -> {:ok, [value]}
    end
  end

  def validate_value(value, :in) when is_list(value) do
    values =
      value
      |> Enum.map(fn
        value when is_integer(value) ->
          value

        value when is_binary(value) ->
          case Integer.parse(value) do
            :error -> nil
            {value, _} -> value
          end

        _ ->
          nil
      end)

    if Enum.find(values, &is_nil/1) do
      {:error, "Invalid integer"}
    else
      {:ok, values}
    end
  end

  def validate_value(value, _op) when is_integer(value) do
    {:ok, value}
  end

  def validate_value(value, _op) when is_binary(value) do
    case Integer.parse(value) do
      :error -> {:error, "Invalid integer"}
      {value, _} -> {:ok, value}
    end
  end

  def validate_value(_value, _op) do
    {:error, "Invalid integer"}
  end
end
