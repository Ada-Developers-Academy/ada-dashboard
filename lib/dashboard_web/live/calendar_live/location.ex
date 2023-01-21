defmodule DashboardWeb.CalendarLive.Location do
  alias Dashboard.Accounts.Claim
  alias Dashboard.Campuses.Campus
  alias Dashboard.Classes
  alias Dashboard.Classes.Class
  alias Dashboard.Cohorts
  alias Dashboard.Cohorts.Cohort
  alias DashboardWeb.CalendarLive.Location

  @enforce_keys [:id, :model, :name]
  defstruct [
    :id,
    :model,
    :name,
    :entity,
    :campus
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
    %Location{id: class.id, model: :class, name: class.name, entity: class}
  end

  def new(%Cohort{} = cohort) do
    %Location{id: cohort.id, model: :cohort, name: "Auditorium", entity: cohort}
  end

  def new(%Claim{cohort: nil, class: class}) do
    campus =
      case class.cohort do
        %Cohort{campus: %Campus{} = campus} -> campus
        _ -> nil
      end

    %Location{id: class.id, model: :class, name: class.name, entity: class, campus: campus}
  end

  def new(%Claim{cohort: cohort, class: nil}) do
    campus =
      case cohort.campus do
        %Campus{} = campus -> campus
        _ -> nil
      end

    %Location{id: cohort.id, model: :cohort, name: "Auditorum", entity: cohort, campus: campus}
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
