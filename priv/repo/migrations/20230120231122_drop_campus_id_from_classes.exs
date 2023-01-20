defmodule Dashboard.Repo.Migrations.DropCampusIdFromClass do
  use Ecto.Migration

  def change do
    alter table(:classes) do
      remove :campus_id
    end
  end
end
