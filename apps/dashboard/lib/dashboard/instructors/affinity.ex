defmodule Dashboard.Instructors.Affinity do
  use Ecto.Schema
  import Ecto.Changeset

  schema "affinities" do
    field :class_id, :id, primary_key: true
    field :instructor_id, :id, primary_key: true
  end

  @doc false
  def changeset(affinity, attrs) do
    affinity
    |> cast(attrs, [])
    |> validate_required([])
  end
end
