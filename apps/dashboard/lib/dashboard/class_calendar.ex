defmodule Dashboard.ClassCalendar do
  use Ecto.Schema
  import Ecto.Changeset

  schema "class_calendar" do
    field :class_id, :id
    field :calendar_id, :id
  end

  @doc false
  def changeset(class_calendar, attrs) do
    class_calendar
    |> cast(attrs, [:class_id, :calendar_id])
    |> validate_required([:class_id, :calendar_id])
  end
end
