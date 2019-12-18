defmodule DomainLogic.Test.LogicFieldTest do
  @moduledoc false

  alias DomainLogic.Test.LogicFieldTest

  defmacro validate_filter_fields(domain) do
    quote do
      filter_fields = unquote(domain).filter_fields()

      Enum.each(filter_fields, fn
        {_name, {field_name, field_type, nil}} ->
          schema_type = unquote(domain).table().__schema__(:type, field_name)
          assert(
            schema_type == field_type ||
              (schema_type == :id && field_type == :integer) ||
              (schema_type == :naive_datetime && field_type == :date) ||
              (schema_type == :utc_datetime && field_type == :date),
            "Invalid filter : #{field_name} #{schema_type} #{field_type}"
          )

        {_name, {field_name, field_type, association}} ->
          assert(
            LogicFieldTest.__validate_filter_association__(
              field_name,
              field_type,
              unquote(domain),
              unquote(domain).table().__schema__(:association, association)
            ),
            "Invalid filter : #{field_name}"
          )
      end)
    end
  end

  defmacro validate_sort_fields(domain) do
    quote do
      sort_fields = unquote(domain).sort_fields()
      schema_fields = unquote(domain).table().__schema__(:fields)

      Enum.each(sort_fields, fn
        {_name, {field_name, nil}} ->
          assert(
            Enum.find(schema_fields, fn name -> name == field_name end),
            "Invalid sort : #{field_name}"
          )

        {_name, {field_name, association}} ->
          assert(
            LogicFieldTest.__validate_sort_association__(
              field_name,
              unquote(domain),
              unquote(domain).table().__schema__(:association, association)
            ),
            "Invalid sort : #{field_name}"
          )
      end)
    end
  end

  def __validate_filter_association__(field_name, field_type, domain, %{through: [parent, child]}) do
    %{queryable: queryable} = domain.table().__schema__(:association, parent)
    %{queryable: queryable} = queryable.__schema__(:association, child)
    schema_type = queryable.__schema__(:type, field_name)
    schema_type == field_type ||
      (schema_type == :id && field_type == :integer) ||
      (schema_type == :naive_datetime && field_type == :date) ||
      (schema_type == :utc_datetime && field_type == :date)
  end

  def __validate_filter_association__(field_name, field_type, _domain, %{queryable: queryable}) do
    schema_type = queryable.__schema__(:type, field_name)
    schema_type == field_type ||
      (schema_type == :id && field_type == :integer) ||
      (schema_type == :naive_datetime && field_type == :date) ||
      (schema_type == :utc_datetime && field_type == :date)
  end

  def __validate_sort_association__(field_name, domain, %{through: [parent, child]}) do
    %{queryable: queryable} = domain.table().__schema__(:association, parent)
    %{queryable: queryable} = queryable.__schema__(:association, child)
    queryable.__schema__(:type, field_name)
  end

  def __validate_sort_association__(field_name, _domain, %{queryable: queryable}) do
    queryable.__schema__(:type, field_name)
  end
end
