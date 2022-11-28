defmodule Dashboard.Repo.Migrations.CreateCalendars do
  use Ecto.Migration

  def change do
    create table(:calendars) do
      add :name, :string
      add :external_id, :string
      add :external_provider, :string

      timestamps()
    end
  end
end
