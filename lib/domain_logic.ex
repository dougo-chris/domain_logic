defmodule Linklab.DomainLogic do
  @moduledoc false

  defmacro __using__(opts) do
    quote do
      use Linklab.DomainLogic.FilterLib
      use Linklab.DomainLogic.SortLib
      use Linklab.DomainLogic.LimitLib
      use Linklab.DomainLogic.PreloadLib
      use Linklab.DomainLogic.FindLib, repo: unquote(opts[:repo]), table: unquote(opts[:table])
    end
  end
end
