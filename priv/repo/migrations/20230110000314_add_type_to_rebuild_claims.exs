defmodule Dashboard.Repo.Migrations.AddTypeToRebuildClaims do
  use Ecto.Migration

  def change do
    alter table(:claims) do
      add :type, :text, null: false
    end
  end
end
