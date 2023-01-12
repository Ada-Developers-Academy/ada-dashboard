defmodule Dashboard.Repo.Migrations.AddCohortToClaims do
  use Ecto.Migration

  def change do
    alter table(:claims) do
      add :cohort_id, references(:cohorts)
      modify :class_id, :id, null: true
    end

    create constraint(:claims, :require_cohort_id_xor_class_id,
             check:
               "(cohort_id is not null and class_id is null) or (cohort_id is null and class_id is not null)"
           )
  end
end
