defmodule Dashboard.Repo.Migrations.MakeExternalIdsRequired do
  use Ecto.Migration

  def change do
    alter table(:calendars) do
      modify(:external_id, :text, null: false)
      modify(:external_provider, :text, null: false)
    end

    alter table(:events) do
      modify(:external_id, :text, null: false)
      modify(:external_provider, :text, null: false)
    end

    alter table(:instructors) do
      modify(:external_id, :text, null: false)
      modify(:external_provider, :text, null: false)
    end
  end
end
