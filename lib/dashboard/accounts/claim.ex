defmodule Dashboard.Accounts.Claim do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "claims" do
    field :instructor_id, :id, primary_key: true
    field :event_id, :id, primary_key: true
    field :type, :string
  end

  @doc false
  def changeset(claim, attrs) do
    claim
    |> cast(attrs, [:instructor_id, :event_id, :type])
    |> validate_required([:instructor_id, :event_id, :type])
  end
end
