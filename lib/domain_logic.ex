defmodule DomainLogic do
  @moduledoc false

  defmacro __using__(opts) do
    quote do
      use DomainLogic.FilterLib
      use DomainLogic.SortLib
      use DomainLogic.LimitLib
      use DomainLogic.PreloadLib
      use DomainLogic.FindLib, repo: unquote(opts[:repo]), table: unquote(opts[:table])
    end
  end
end
