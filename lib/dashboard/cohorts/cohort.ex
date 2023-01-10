defmodule Dashboard.Cohorts.Cohort do
  use Ecto.Schema
  import Ecto.Changeset

  alias Dashboard.Classes.Class

  schema "cohorts" do
    field :name, :string

    has_many :classes, Class

    timestamps()
  end

  @doc false
  def changeset(cohort, attrs) do
    cohort
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
