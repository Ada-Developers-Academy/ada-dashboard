defmodule Dashboard.Calendars.Calendar do
  use Ecto.Schema
  import Ecto.Changeset

  alias Dashboard.Calendars.Event

  schema "calendars" do
    field :external_id, :string
    field :external_provider, :string
    field :name, :string
    field :timezone, :string
    field :is_personal, :boolean

    has_many :events, Event

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(calendar, attrs) do
    calendar
    |> cast(attrs, [:name, :external_id, :external_provider, :timezone, :is_personal])
    |> unique_constraint([:external_id, :external_provider])
    |> validate_required([:name, :external_id, :external_provider, :timezone, :is_personal])
  end
end
