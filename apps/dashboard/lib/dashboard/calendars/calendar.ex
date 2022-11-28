defmodule Dashboard.Calendars.Calendar do
  use Ecto.Schema
  import Ecto.Changeset

  schema "calendars" do
    field :external_id, :string
    field :external_provider, :string
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(calendar, attrs) do
    calendar
    |> cast(attrs, [:name, :external_id, :external_provider])
    |> validate_required([:name, :external_id, :external_provider])
  end
end
