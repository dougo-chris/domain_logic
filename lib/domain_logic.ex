defmodule Linklab.DomainLogic do
  @moduledoc false

  defmacro __using__(opts) do
    repo = opts[:repo]

    quote do
      use Linklab.DomainLogic.FilterLib
      use Linklab.DomainLogic.SortLib
      use Linklab.DomainLogic.LimitLib
      use Linklab.DomainLogic.PreloadLib
      use Linklab.DomainLogic.FindLib, repo: unquote(repo)
    end
  end
end
