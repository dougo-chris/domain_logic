defmodule DomainLogic.Domain do
  @moduledoc false

  defmacro __using__(opts) do
    quote do
      use DomainLogic.Domain.FilterLib
      use DomainLogic.Domain.SortLib
      use DomainLogic.Domain.LimitLib
      use DomainLogic.Domain.PreloadLib
      use DomainLogic.Domain.FindLib, repo: unquote(opts[:repo]), table: unquote(opts[:table])
    end
  end
end
