defmodule Dashboard.Repo.Migrations.FixCalendars do
  use Ecto.Migration

  def change do
    alter table(:calendars) do
      modify(:name, :text, null: false)
      modify(:timezone, :text, null: false)
    end

    rename table(:campus), to: table(:campuses)

    alter table(:campuses) do
      modify(:name, :text, null: false)
    end

    alter table(:classes) do
      modify(:name, :text, null: false)
    end

    rename table(:cohort), to: table(:cohorts)

    alter table(:cohorts) do
      modify(:name, :text, null: false)
    end

    alter table(:events) do
      modify(:title, :text, null: false)
    end

    alter table(:instructors) do
      modify(:name, :text, null: false)
      modify(:email, :text, null: false)
    end
  end
end
