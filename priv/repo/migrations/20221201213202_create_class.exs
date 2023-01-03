defmodule Dashboard.Repo.Migrations.CreateClass do
  use Ecto.Migration

  def change do
    create table(:classes) do
      add :name, :text
      add :campus_id, references(:campus, on_delete: :nothing)
      add :cohort_id, references(:cohort, on_delete: :nothing)

      timestamps()
    end

    create index(:classes, [:campus_id])
    create index(:classes, [:cohort_id])
  end
end
