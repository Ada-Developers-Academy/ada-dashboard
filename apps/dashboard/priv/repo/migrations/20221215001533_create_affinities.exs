defmodule Dashboard.Repo.Migrations.CreateAffinities do
  use Ecto.Migration

  def change do
    create table(:affinities, primary_key: false) do
      add :class_id, references(:classes), primary_key: true
      add :instructor_id, references(:instructors), primary_key: true
    end

    create unique_index(:affinities, [:class_id, :instructor_id])
  end
end
