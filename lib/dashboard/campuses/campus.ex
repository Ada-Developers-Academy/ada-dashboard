defmodule Dashboard.Campuses.Campus do
  use Ecto.Schema
  import Ecto.Changeset

  alias Dashboard.Accounts.Instructor
  alias Dashboard.Cohorts.Cohort

  schema "campuses" do
    field :name, :string

    has_many :cohorts, Cohort
    many_to_many :instructors, Instructor, join_through: "residences"

    timestamps()
  end

  @doc false
  def changeset(campus, attrs) do
    campus
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
