defmodule Dashboard.Repo.Migrations.AddFieldsToEvents do
  use Ecto.Migration

  def change do
    rename table(:events), :name, to: :title

    alter table(:events) do
      add :calendar_id, references(:calendars)
      add :start_time, :timestamptz
      add :end_time, :timestamptz
      add :location, :string
    end
  end
end
