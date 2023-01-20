# This is basically a Claim but with some extra fields.
defmodule Dashboard.Accounts.ClaimRow do
  @enforce_keys [:claim, :instructor, :location, :type]
  defstruct [:claim, :instructor, :location, :type]

  import Ecto.Query, warn: false

  alias Dashboard.Accounts.Claim
  alias Dashboard.Accounts.ClaimRow
  alias Dashboard.Repo
  alias DashboardWeb.CalendarLive.Location

  def claims_from_locations_by_locality_by_event_id(locations) do
    class_ids =
      locations
      |> Enum.filter(fn l -> l.model == :class end)
      |> Enum.map(fn c -> c.id end)

    cohort_ids =
      locations
      |> Enum.filter(fn l -> l.model == :cohort end)
      |> Enum.map(fn c -> c.id end)

    Repo.all(
      from claim in Claim,
        left_join: class in Class,
        on: claim.class_id == class.id,
        left_join: cohort in Cohort,
        on: claim.cohort_id == cohort.id,
        where: class.id in ^class_ids or cohort.id in ^cohort_ids,
        distinct: true,
        preload: [
          class: [cohort: [:campus]],
          cohort: [:campus],
          instructor: [:campuses],
          event: []
        ]
    )
    |> Enum.map(fn claim ->
      %ClaimRow{
        claim: claim,
        type: claim.type,
        instructor: claim.instructor,
        location: Location.new(claim)
      }
    end)
    |> Enum.group_by(fn row ->
      nil
    end)
  end
end
