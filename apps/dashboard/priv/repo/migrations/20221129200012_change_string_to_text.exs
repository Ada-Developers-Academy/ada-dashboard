defmodule Dashboard.Repo.Migrations.ChangeStringToText do
  use Ecto.Migration

  def change do
    alter table(:calendars) do
      modify :external_id, :text
      modify :external_provider, :text
      modify :name, :text
      modify :timezone, :text
    end

    alter table(:events) do
      modify :external_id, :text
      modify :external_provider, :text
      modify :title, :text
      modify :description, :text
      modify :location, :text
    end

    alter table(:instructors) do
      modify :name, :text
      modify :email, :text
      modify :external_id, :text
      modify :external_provider, :text
      modify :background_color, :text
    end
  end
end
