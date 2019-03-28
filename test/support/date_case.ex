defmodule Linklab.DomainLogic.DataCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to the application's data layer.

  You may define functions here to be used as helpers in
  your tests.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """
  use ExUnit.CaseTemplate

  alias Ecto.Adapters.SQL.Sandbox

  using do
    quote do
      alias Linklab.DomainLogic.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query

      import Linklab.DomainLogic.Factory

      import Linklab.DomainLogic.DataCase
      import Linklab.DomainLogic.Test.FilterInteger
      import Linklab.DomainLogic.Test.FilterString
      import Linklab.DomainLogic.Test.FilterBoolean
      import Linklab.DomainLogic.Test.SortInteger
      import Linklab.DomainLogic.Test.SortString
    end
  end

  setup tags do
    :ok = Sandbox.checkout(Linklab.DomainLogic.Repo)

    unless tags[:async] do
      Sandbox.mode(Linklab.DomainLogic.Repo, {:shared, self()})
    end

    :ok
  end
end
