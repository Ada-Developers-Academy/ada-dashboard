defmodule Dashboard.Repo.Migrations.RebuildClassCalendars do
  use Ecto.Migration

  def change do
    drop_if_exists table(:class_calendars)

    create table(:class_calendars, primary_key: false) do
      add :class_id, references(:classes), primary_key: true
      add :calendar_id, references(:calendars), primary_key: true
    end

    create unique_index(:class_calendars, [:class_id, :calendar_id])
  end
end
