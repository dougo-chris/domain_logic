defmodule Turbo.Ecto.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:dl_categories) do
      add :title, :string
      add :code, :integer

      timestamps(type: :utc_datetime)
    end
    alter table(:dl_categories) do
      modify(:inserted_at, :timestamp, default: fragment("NOW()"))
      modify(:updated_at,  :timestamp, default: fragment("NOW()"))
    end

    create table(:dl_products) do
      add :category_id, references(:dl_categories), null: false
      add :name, :string
      add :price, :integer
      add :available, :boolean

      timestamps(type: :utc_datetime)
    end
    alter table(:dl_products) do
      modify(:inserted_at, :timestamp, default: fragment("NOW()"))
      modify(:updated_at,  :timestamp, default: fragment("NOW()"))
    end
    create index(:dl_products, [:category_id])

    create table(:dl_variants) do
      add :product_id, references(:dl_products), null: false
      add :code,    :string

      timestamps(type: :utc_datetime)
    end
    alter table(:dl_variants) do
      modify(:inserted_at, :timestamp, default: fragment("NOW()"))
      modify(:updated_at,  :timestamp, default: fragment("NOW()"))
    end
    create index(:dl_variants, [:product_id])
  end
end
