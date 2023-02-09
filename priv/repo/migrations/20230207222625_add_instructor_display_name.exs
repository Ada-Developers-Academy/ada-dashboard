defmodule Dashboard.Repo.Migrations.AddInstructorDisplayName do
  use Ecto.Migration

  import Ecto.Query

  alias Dashboard.Accounts
  alias Dashboard.Repo

  def up do
    alter table(:instructors) do
      add :display_name, :text, null: true
    end

    flush()

    # Backfill
    instructors = Accounts.list_instructors()

    Enum.each(instructors, fn i ->
      Accounts.update_instructor(i, %{display_name: List.first(String.split(i.name))})
    end)

    alter table(:instructors) do
      modify :display_name, :text, null: false
    end
  end

  def down do
    alter table(:instructors) do
      remove :display_name
    end
  end
end
