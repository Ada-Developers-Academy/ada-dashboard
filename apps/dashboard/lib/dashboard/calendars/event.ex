defmodule Dashboard.Calendars.Event do
  use Ecto.Schema
  import Ecto.Changeset

  schema "events" do
    field :external_id, :string
    field :external_provider, :string
    field :calendar_id, :id
    field :title, :string
    field :description, :string
    field :location, :string
    field :start_time, :utc_datetime
    field :end_time, :utc_datetime

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
      :end_time
    ])
    |> unique_constraint([:external_id, :external_provider])
    |> validate_required([:external_id, :external_provider, :calendar_id, :title])
  end
end
