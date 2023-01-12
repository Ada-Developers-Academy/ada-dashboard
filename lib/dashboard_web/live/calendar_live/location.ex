defmodule DashboardWeb.CalendarLive.Location do
  alias DashboardWeb.CalendarLive.Location
  alias Dashboard.Accounts.Claim
  alias Dashboard.Cohorts
  alias Dashboard.Cohorts.Cohort
  alias Dashboard.Classes
  alias Dashboard.Classes.Class

  @enforce_keys [:id, :model, :name]
  defstruct [
    :id,
    :model,
    :name
  ]

  def get!(string) when is_binary(string) do
    [type, raw_id] = String.split(string, "/")
    {id, ""} = Integer.parse(raw_id)

    case type do
      "class" -> new(Classes.get_class!(id))
      "cohort" -> new(Cohorts.get_cohort!(id))
    end
  end

  def new(%Class{} = class) do
    %Location{id: class.id, model: :class, name: class.name}
  end

  def new(%Cohort{} = cohort) do
    %Location{id: cohort.id, model: :cohort, name: "Auditorium"}
  end

  def new(%Claim{cohort_id: nil, class_id: class_id}, name) do
    %Location{id: class_id, model: :class, name: name}
  end

  def new(%Claim{cohort_id: cohort_id, class_id: nil}, _name) do
    %Location{id: cohort_id, model: :cohort, name: "Auditorum"}
  end

  defimpl String.Chars, for: __MODULE__ do
    def to_string(%Location{id: id, model: :class}) do
      "class/#{id}"
    end

    def to_string(%Location{id: id, model: :cohort}) do
      "cohort/#{id}"
    end
  end
end
