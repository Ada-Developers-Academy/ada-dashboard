defmodule Dashboard.Repo.Migrations.RebuildClaims do
  use Ecto.Migration

  def change do
    drop_if_exists table(:claims)

    create table(:claims, primary_key: false) do
      add :instructor_id, references(:instructors), primary_key: true
      add :event_id, references(:events), primary_key: true
    end

    create unique_index(:claims, [:instructor_id, :event_id])
  end
end
