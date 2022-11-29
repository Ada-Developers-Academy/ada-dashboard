defmodule Dashboard.Repo.Migrations.AddTimezoneToCalendar do
  use Ecto.Migration

  def change do
    alter table("calendars") do
      add :timezone, :string
    end
  end
end
