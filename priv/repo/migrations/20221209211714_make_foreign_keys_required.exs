defmodule Dashboard.Repo.Migrations.MakeForeignKeysRequired do
  use Ecto.Migration

  def change do
    alter table(:classes) do
      modify(:cohort_id, :bigint, null: false)
      modify(:campus_id, :bigint, null: false)
    end

    alter table(:claims) do
      modify(:event_id, :bigint, null: false)
      modify(:instructor_id, :bigint, null: false)
    end

    alter table(:events) do
      modify(:calendar_id, :bigint, null: false)
    end
  end
end
