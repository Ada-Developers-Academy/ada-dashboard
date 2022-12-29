defmodule Dashboard.Repo.Migrations.RequireStartAndEndTimes do
  use Ecto.Migration

  def change do
    alter table(:events) do
      modify(:start_time, :timestamptz, null: false)
      modify(:end_time, :timestamptz, null: false)
    end
  end
end
