defmodule Linklab.DomainLogic.PreloadLib do
  @moduledoc false

  import Ecto.Query

  @type preload :: atom() | list(atom()) | keyword()

  @callback preload_with(Ecto.Schema.t(), preload()) :: Ecto.Queryable.t()

  defmacro __using__(_opts) do
    quote do
      import Linklab.DomainLogic.PreloadLib

      @behaviour Linklab.DomainLogic.PreloadLib

      @impl true
      @spec preload_with(Ecto.Queryable.t(), PreloadLib.preload) :: Ecto.Queryable.t()
      def preload_with(query, associations) do
        Linklab.DomainLogic.PreloadLib.__preload_builder__(query, associations)
      end
    end
  end

  def __preload_builder__(query, associations) do
    from(q in query, preload: ^associations)
  end
end
