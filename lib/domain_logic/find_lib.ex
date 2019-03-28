defmodule Linklab.DomainLogic.FindLib do
  @moduledoc false

  @callback repo() :: Ecto.Repo.t()

  @callback find(Ecto.Queryable.t(), {atom(), any()} | list({atom(), any()})) ::
              {:ok, Ecto.Schema.t()} | {:error, String.t()}
  @callback find({atom(), any()} | list({atom(), any()})) ::
              {:ok, Ecto.Schema.t()} | {:error, String.t()}

  @callback one(Ecto.Queryable.t()) :: {:ok, Ecto.Schema.t()} | {:error, String.t()}
  @callback one() :: {:ok, Ecto.Schema.t()} | {:error, String.t()}

  @callback all(Ecto.Queryable.t()) :: [Ecto.Schema.t()]
  @callback all() :: [Ecto.Schema.t()]

  @callback paginate(Ecto.Queryable.t(), {non_neg_integer, non_neg_integer}) :: Scrivener.Page.t()
  @callback paginate({non_neg_integer, non_neg_integer}) :: Scrivener.Page.t()

  @callback count(Ecto.Queryable.t()) :: integer
  @callback count() :: integer

  defmacro __using__(opts) do
    quote do
      @behaviour Linklab.DomainLogic.FindLib

      @repo unquote(opts[:repo])
      @table unquote(opts[:table])

      @doc """
      Repo used by the domain
      """
      @impl true
      @spec repo() :: Ecto.Repo.t()
      def repo, do: @repo

      @doc """
      Fetch a Records by the query and field == value
      """
      @impl true
      @spec find(Ecto.Queryable.t(), {atom(), any()} | list({atom(), any()})) ::
              {:ok, Ecto.Schema.t()} | {:error, String.t()}
      def find(query, params) when is_list(params) do
        case @repo.get_by(query, params) do
          nil ->
            {:error, "Not found"}

          record ->
            {:ok, record}
        end
      end

      def find(query, params), do: find(query, [params])

      @doc """
      Fetch a Records for the table by field == value
      """
      @impl true
      @spec find({atom(), any()} | list({atom(), any()})) ::
              {:ok, Ecto.Schema.t()} | {:error, String.t()}
      def find(params), do: find(@table, params)

      @doc """
      Fetch first Record by the query
      """
      @impl true
      @spec one(Ecto.Queryable.t()) :: {:ok, Ecto.Schema.t()} | {:error, String.t()}
      def one(query) do
        case @repo.one(query) do
          nil ->
            {:error, "Not found"}

          record ->
            {:ok, record}
        end
      end

      @doc """
      Fetch first Record for the table
      """
      @impl true
      @spec one() :: {:ok, Ecto.Schema.t()} | {:error, String.t()}
      def one, do: one(@table)

      @doc """
      Fetch all Records by the query
      """
      @impl true
      @spec all(Ecto.Queryable.t()) :: [Ecto.Schema.t()]
      def all(query) do
        @repo.all(query)
      end

      @doc """
      Fetch all Records for the table
      """
      @impl true
      @spec all() :: [Ecto.Schema.t()]
      def all, do: all(@table)

      @doc """
      Fetch a page of Records by the query
      """
      @impl true
      @spec paginate(Ecto.Queryable.t(), {non_neg_integer, non_neg_integer}) :: Scrivener.Page.t()
      def paginate(query, {page, page_size}) do
        @repo.paginate(query, page: page, page_size: page_size)
      end

      @doc """
      Fetch a page of Records for the table
      """
      @impl true
      @spec paginate({non_neg_integer, non_neg_integer}) :: Scrivener.Page.t()
      def paginate({page, page_size}), do: paginate(@table, {page, page_size})

      @doc """
      Count then Records by the query
      """
      @impl true
      @spec count(Ecto.Queryable.t()) :: integer
      def count(query) do
        @repo.aggregate(query, :count, :id)
      end

      @doc """
      Count then Records for the table
      """
      @impl true
      @spec count() :: integer
      def count, do: count(@table)
    end
  end
end
