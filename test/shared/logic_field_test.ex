defmodule DomainLogic.Test.LogicFieldTest do
  @moduledoc false

  defmacro validate_filter_fields(domain) do
    # credo:disable-for-next-line Credo.Check.Refactor.LongQuoteBlocks
    quote do
      filter_fields = unquote(domain).filter_fields()

      Enum.each(filter_fields, fn
        {_name, {field_name, field_type, nil}} ->
          schema_type = unquote(domain).table().__schema__(:type, field_name)
          assert schema_type == field_type || (schema_type == :id && field_type == :integer)

        {_name, {field_name, field_type, association}} ->
          %{queryable: queryable} = unquote(domain).table().__schema__(:association, association)
          schema_type = queryable.__schema__(:type, field_name)
          assert schema_type == field_type || (schema_type == :id && field_type == :integer)
      end)
    end
  end

  defmacro validate_sort_fields(domain) do
    # credo:disable-for-next-line Credo.Check.Refactor.LongQuoteBlocks
    quote do
      sort_fields = unquote(domain).sort_fields()
      schema_fields = unquote(domain).table().__schema__(:fields)

      Enum.each(sort_fields, fn
        {_name, {field_name, nil}} ->
          assert Enum.find(schema_fields, fn name -> name == field_name end)

        {_name, {field_name, association}} ->
          %{queryable: queryable} = unquote(domain).table().__schema__(:association, association)
          assert queryable.__schema__(:type, field_name)
      end)
    end
  end
end
