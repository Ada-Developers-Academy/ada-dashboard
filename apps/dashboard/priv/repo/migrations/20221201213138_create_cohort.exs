defmodule Dashboard.Repo.Migrations.CreateCohort do
  use Ecto.Migration

  def change do
    create table(:cohort) do
      add :name, :text

      timestamps()
    end
  end
end
