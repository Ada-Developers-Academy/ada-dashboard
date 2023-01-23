defmodule Dashboard.Repo.Migrations.RequireUniqueGuestInstructorNames do
  use Ecto.Migration

  def change do
    create unique_index(:instructors, [:name, :email, :external_provider, :external_id, :is_guest])
  end
end
