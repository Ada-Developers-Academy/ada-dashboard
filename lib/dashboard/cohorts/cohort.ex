defmodule Dashboard.Cohorts.Cohort do
  use Ecto.Schema
  import Ecto.Changeset

  alias Dashboard.Classes.Class
  alias Dashboard.Campuses.Campus

  schema "cohorts" do
    field :name, :string

    has_many :classes, Class
    belongs_to :campus, Campus

    timestamps()
  end

  @doc false
  def changeset(cohort, attrs) do
    cohort
    |> cast(attrs, [:name, :campus_id])
    |> validate_required([:name, :campus_id])
  end
end
