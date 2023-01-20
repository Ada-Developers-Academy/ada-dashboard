defmodule Dashboard.Repo.Migrations.AddCampusIdToCohort do
  use Ecto.Migration

  alias Dashboard.Repo
  alias Dashboard.Campuses.Campus
  alias Dashboard.Cohorts.Cohort

  def change do
    alter table(:cohorts) do
      add :campus_id, :id
    end

    flush()

    # Backfill that's only safe with a single campus!
    campus = Repo.one!(Campus)
    Repo.update_all(Cohort, set: [campus_id: campus.id])

    alter table(:cohorts) do
      modify :campus_id, references(:campuses), null: false
    end
  end
end
