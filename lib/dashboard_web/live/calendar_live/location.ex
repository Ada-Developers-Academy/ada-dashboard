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
    :campus_id
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
    %Location{
      id: class.id,
      model: :class,
      name: class.name,
      campus_id: get_campus_id(class)
    }
  end

  def new(%Cohort{} = cohort) do
    %Location{
      id: cohort.id,
      model: :cohort,
      name: "Auditorium",
      campus_id: get_campus_id(cohort)
    }
  end

  def new(%Claim{cohort: nil, class: class}) do
    %Location{
      id: class.id,
      model: :class,
      name: class.name,
      campus_id: get_campus_id(class)
    }
  end

  def new(%Claim{cohort: cohort, class: nil}) do
    %Location{
      id: cohort.id,
      model: :cohort,
      name: "Auditorum",
      campus_id: get_campus_id(cohort)
    }
  end

  defp get_campus_id(entity) do
    case entity do
      %Cohort{campus: %Campus{} = campus} -> campus.id
      %Class{cohort: %Cohort{campus: %Campus{} = campus}} -> campus.id
      _ -> nil
    end
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
