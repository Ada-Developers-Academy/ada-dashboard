defmodule Dashboard.Accounts.Affinity do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "affinities" do
    field :class_id, :id, primary_key: true
    field :instructor_id, :id, primary_key: true
  end

  @doc false
  def changeset(affinity, attrs) do
    affinity
    |> cast(attrs, [:class_id, :instructor_id])
    |> validate_required([:class_id, :instructor_id])
  end
end
