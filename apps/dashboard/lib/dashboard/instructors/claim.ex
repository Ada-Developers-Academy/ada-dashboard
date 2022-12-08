defmodule Dashboard.Instructors.Claim do
  use Ecto.Schema
  import Ecto.Changeset

  schema "claims" do
    field :instructor_id, :id
    field :event_id, :id
  end

  @doc false
  def changeset(claim, attrs) do
    claim
    |> cast(attrs, [])
    |> validate_required([])
  end
end
