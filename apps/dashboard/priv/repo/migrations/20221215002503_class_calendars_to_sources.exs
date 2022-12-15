defmodule Dashboard.Repo.Migrations.ClassCalendarsToSources do
  use Ecto.Migration

  def change do
    drop table(:class_calendars)

    create table(:sources, primary_key: false) do
      add :class_id, references(:classes), primary_key: true
      add :calendar_id, references(:calendars), primary_key: true
    end

    create unique_index(:sources, [:class_id, :calendar_id])
  end
end
