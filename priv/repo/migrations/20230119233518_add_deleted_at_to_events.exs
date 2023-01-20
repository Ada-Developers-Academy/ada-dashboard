defmodule Dashboard.Repo.Migrations.AddIsDeletedToCalendarEvents do
  use Ecto.Migration

  def change do
    alter table(:events) do
      add :deleted_at, :timestamptz
    end
  end
end
