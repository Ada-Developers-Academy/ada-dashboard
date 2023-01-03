defmodule Dashboard.Repo.Migrations.ChangeTimestampsToTimestamptz do
  use Ecto.Migration

  def change do
    alter table(:calendars) do
      modify :inserted_at, :timestamptz
      modify :updated_at, :timestamptz
    end

    alter table(:events) do
      modify :inserted_at, :timestamptz
      modify :updated_at, :timestamptz
    end

    alter table(:instructors) do
      modify :inserted_at, :timestamptz
      modify :updated_at, :timestamptz
    end
  end
end
