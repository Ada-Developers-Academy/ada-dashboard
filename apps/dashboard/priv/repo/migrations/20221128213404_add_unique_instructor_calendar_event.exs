defmodule Dashboard.Repo.Migrations.AddUniqueCalendarEvent do
  use Ecto.Migration

  def change do
    create unique_index(:instructors, [:external_id, :external_provider])
    create unique_index(:calendars, [:external_id, :external_provider])
    create unique_index(:events, [:external_id, :external_provider])
  end
end
