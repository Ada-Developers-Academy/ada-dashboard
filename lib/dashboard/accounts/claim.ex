defmodule Dashboard.Accounts.Claim do
  use Ecto.Schema
  import Ecto.Changeset

  alias Dashboard.Classes.Class
  alias Dashboard.Cohorts.Cohort

  @primary_key false
  schema "claims" do
    field :instructor_id, :id, primary_key: true
    field :event_id, :id, primary_key: true
    field :class_id, :id
    field :cohort_id, :id
    field :type, :string
  end

  @doc false
  def changeset(claim, attrs) do
    claim
    |> cast(attrs, [:instructor_id, :event_id, :class_id, :cohort_id, :type])
    |> validate_required([:instructor_id, :event_id, :cohort_id, :class_id, :type])
  end
end
