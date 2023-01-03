defmodule Dashboard.Repo.Migrations.CreateCampus do
  use Ecto.Migration

  def change do
    create table(:campus) do
      add :name, :text

      timestamps()
    end
  end
end
