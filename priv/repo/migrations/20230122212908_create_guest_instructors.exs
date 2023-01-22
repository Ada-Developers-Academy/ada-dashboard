defmodule Dashboard.Repo.Migrations.CreateGuestInstructors do
  use Ecto.Migration

  def change do
    alter table(:instructors) do
      modify :email, :text, null: true
      modify :external_provider, :text, null: true
      modify :external_id, :text, null: true
      add :is_guest, :boolean
    end

    create constraint(:instructors, :require_instructor_info_or_guest,
             check:
               "is_guest or (email is not null and external_provider is not null and external_id is not null)"
           )
  end
end
