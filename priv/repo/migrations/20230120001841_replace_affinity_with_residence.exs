defmodule Dashboard.Repo.Migrations.ReplaceAffinityWithResidence do
  use Ecto.Migration

  def change do
    drop table(:affinities)

    create table(:residences, primary_key: false) do
      add :instructor_id, references(:instructors), primary_key: true
      add :campus_id, references(:campuses), primary_key: true
    end

    create unique_index(:residences, [:instructor_id, :campus_id])
  end
end
