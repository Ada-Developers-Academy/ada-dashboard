defmodule Dashboard.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :name, :string
      add :description, :string
      add :external_id, :string
      add :external_provider, :string

      timestamps()
    end
  end
end
