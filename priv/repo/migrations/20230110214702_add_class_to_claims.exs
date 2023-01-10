defmodule Dashboard.Repo.Migrations.AddClassToClaims do
  use Ecto.Migration

  def change do
    alter table(:claims) do
      add :class_id, references(:classes), null: false
    end
  end
end
