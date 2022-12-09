defmodule Dashboard.Classes.Class do
  use Ecto.Schema
  import Ecto.Changeset

  schema "classes" do
    field :name, :string
    field :campus_id, :id
    field :cohort_id, :id

    many_to_many :calendars, Dashboard.ClassCalendar, join_through: "class_calendars"

    timestamps()
  end

  @doc false
  def changeset(class, attrs) do
    class
    |> cast(attrs, [:name, :campus_id, :cohort_id])
    |> validate_required([:name, :campus_id, :cohort_id])
  end
end
