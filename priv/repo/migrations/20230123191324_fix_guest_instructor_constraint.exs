defmodule Dashboard.Repo.Migrations.FixGuestInstructorConstraint do
  use Ecto.Migration

  def change do
    drop constraint(:instructors, :require_instructor_info_or_guest)

    create constraint(:instructors, :require_instructor_info_or_guest,
             check:
               "is_guest or (email is not null and external_provider is not null and external_id is not null)"
           )
  end
end
