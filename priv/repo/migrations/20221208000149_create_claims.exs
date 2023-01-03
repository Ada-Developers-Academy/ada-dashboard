defmodule Dashboard.Repo.Migrations.CreateClaims do
  use Ecto.Migration

  def change do
    create table(:claims, primary_key: false) do
      add :instructor_id, references(:instructors, on_delete: :nothing)
      add :event_id, references(:events, on_delete: :nothing)
    end

    create index(:claims, [:instructor_id])
    create index(:claims, [:event_id])
  end
end
