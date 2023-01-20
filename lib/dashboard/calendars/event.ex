defmodule Dashboard.Calendars.Event do
  use Ecto.Schema
  import Ecto.Changeset

  alias Dashboard.Calendars.Calendar

  schema "events" do
    field :external_id, :string
    field :external_provider, :string
    field :title, :string
    field :description, :string
    field :location, :string
    field :start_time, :utc_datetime
    field :end_time, :utc_datetime
    field :deleted_at, :utc_datetime

    belongs_to :calendar, Calendar

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [
      :external_id,
      :external_provider,
      :calendar_id,
      :title,
      :description,
      :location,
      :start_time,
      :end_time,
      :deleted_at
    ])
    |> unique_constraint([:external_id, :external_provider])
    |> validate_required([
      :external_id,
      :external_provider,
      :calendar_id,
      :title,
      :start_time,
      :end_time
    ])
  end
end
