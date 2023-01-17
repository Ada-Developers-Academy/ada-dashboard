defmodule Dashboard.Accounts.Claim do
  use Ecto.Schema
  import Ecto.Changeset

  alias Dashboard.Accounts.Instructor
  alias Dashboard.Calendars.Event
  alias Dashboard.Classes.Class
  alias Dashboard.Cohorts.Cohort

  @primary_key false
  schema "claims" do
    belongs_to :instructor, Instructor, primary_key: true
    belongs_to :event, Event, primary_key: true
    belongs_to :class, Class
    belongs_to :cohort, Cohort

    field :type, :string
  end

  @doc false
  def changeset(claim, attrs) do
    claim
    |> cast(attrs, [:instructor_id, :event_id, :class_id, :cohort_id, :type])
    |> validate_required([:instructor_id, :event_id, :cohort_id, :class_id, :type])
  end
end
