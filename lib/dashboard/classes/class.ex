defmodule Dashboard.Classes.Class do
  use Ecto.Schema
  import Ecto.Changeset

  alias Dashboard.Cohorts.Cohort
  alias Dashboard.Calendars.Calendar

  schema "classes" do
    field :name, :string

    belongs_to :cohort, Cohort
    many_to_many :calendars, Calendar, join_through: "sources"

    timestamps()
  end

  @doc false
  def changeset(class, attrs) do
    class
    |> cast(attrs, [:name, :cohort_id])
    |> foreign_key_constraint(:cohort)
    |> validate_required([:name, :cohort_id])
  end
end
