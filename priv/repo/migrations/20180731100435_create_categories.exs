defmodule Turbo.Ecto.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:dl_categories) do
      add :name, :string

      timestamps()
    end
  end
end
