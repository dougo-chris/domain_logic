defmodule DomainLogic.DomainQuery do
  @moduledoc false

  defmacro __using__(opts) do
    quote do
      use DomainLogic.DomainQuery.FilterLib
      use DomainLogic.DomainQuery.SortLib
      use DomainLogic.DomainQuery.LimitLib
      use DomainLogic.DomainQuery.PreloadLib
      use DomainLogic.DomainQuery.FindLib, repo: unquote(opts[:repo]), table: unquote(opts[:table])
    end
  end
end
