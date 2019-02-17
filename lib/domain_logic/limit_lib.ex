defmodule Linklab.DomainLogic.LimitLib do
  @moduledoc false

  import Ecto.Query

  alias Linklab.DomainLogic.LimitLib

  @type limit :: integer | {integer, integer}

  @callback limit_by(Ecto.Queryable.t(), limit) :: Ecto.Queryable.t()

  defmacro __using__(_opts) do
    quote do
      import Linklab.DomainLogic.LimitLib

      @behaviour Linklab.DomainLogic.LimitLib

      @impl true
      @callback limit_by(Ecto.Queryable.t(), LimitLib.limit()) :: Ecto.Queryable.t()
      def limit_by(query, limit) do
        Linklab.DomainLogic.LimitLib.__limit_builder__(query, limit)
      end
    end
  end

  def __limit_builder__(query, {offset, size}) do
    from(q in query, offset: ^offset, limit: ^size)
  end

  def __limit_builder__(query, size), do: __limit_builder__(query, {0, size})
end
