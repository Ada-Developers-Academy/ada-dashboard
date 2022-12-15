# TODO: Fold this into classes.ex or calendars.ex or make a separate context
defmodule Dashboard.ClassCalendar do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "class_calendars" do
    field :class_id, :id, primary_key: true
    field :calendar_id, :id, primary_key: true
  end

  @doc false
  def changeset(class_calendar, attrs) do
    class_calendar
    |> cast(attrs, [:class_id, :calendar_id])
    |> validate_required([:class_id, :calendar_id])
  end
end
