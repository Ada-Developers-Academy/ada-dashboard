defmodule Dashboard.Cohorts.Cohort do
  use Ecto.Schema
  import Ecto.Changeset

  schema "cohorts" do
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(cohort, attrs) do
    cohort
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
