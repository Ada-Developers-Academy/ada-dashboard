defmodule Dashboard.Accounts.Residence do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "residences" do
    field :campus_id, :id, primary_key: true
    field :instructor_id, :id, primary_key: true
  end

  @doc false
  def changeset(affinity, attrs) do
    affinity
    |> cast(attrs, [:campus_id, :instructor_id])
    |> validate_required([:campus_id, :instructor_id])
  end
end
