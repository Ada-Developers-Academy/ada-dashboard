defmodule Dashboard.Repo.Migrations.CreateInstructors do
  use Ecto.Migration

  def change do
    create table(:instructors) do
      add :name, :string
      add :email, :string
      add :external_id, :string
      add :external_provider, :string
      add :background_color, :string, null: true

      timestamps()
    end
  end
end
