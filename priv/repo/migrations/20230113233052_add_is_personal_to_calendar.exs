defmodule Dashboard.Repo.Migrations.AddIsPersonalToCalendar do
  use Ecto.Migration

  def change do
    alter table(:calendars) do
      add :is_personal, :boolean, null: false, default: false
    end
  end
end
