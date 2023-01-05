defmodule Dashboard.Repo.Migrations.AddStartTimeIndexToEvents do
  use Ecto.Migration

  def change do
    create index(:events, [:start_time])
  end
end
