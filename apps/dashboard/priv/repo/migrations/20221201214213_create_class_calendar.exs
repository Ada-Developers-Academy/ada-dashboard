defmodule Dashboard.Repo.Migrations.CreateClassCalendar do
  use Ecto.Migration

  def change do
    create table(:class_calendar, primary_key: false) do
      add :class_id, references(:classes, on_delete: :nothing)
      add :calendar_id, references(:calendars, on_delete: :nothing)
    end

    create index(:class_calendar, [:class_id])
    create index(:class_calendar, [:calendar_id])
  end
end
