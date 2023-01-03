defmodule Dashboard.Repo.Migrations.RebuildConstraints do
  use Ecto.Migration

  def change do
    drop constraint(:classes, "classes_campus_id_fkey")
    drop constraint(:classes, "classes_cohort_id_fkey")

    alter table(:classes) do
      modify :campus_id, references(:campuses)
      modify :cohort_id, references(:cohorts)
    end
  end
end
