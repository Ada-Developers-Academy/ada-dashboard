defmodule Dashboard.Repo.Migrations.GuestInstructorsPartialUniqueConstraint do
  use Ecto.Migration

  def change do
    drop unique_index(:instructors, [:name, :email, :external_provider, :external_id, :is_guest])

    create unique_index(
             :instructors,
             [:name],
             where: "is_guest = true"
           )
  end
end
