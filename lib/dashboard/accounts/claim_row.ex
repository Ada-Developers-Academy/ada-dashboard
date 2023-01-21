# This is basically a Claim but with some extra fields.
defmodule Dashboard.Accounts.ClaimRow do
  @enforce_keys [:claim, :event, :instructor, :location, :type]
  defstruct [:claim, :event, :instructor, :location, :type]

  import Ecto.Query, warn: false

  alias Dashboard.Accounts.Claim
  alias Dashboard.Accounts.ClaimRow
  alias Dashboard.Accounts.Instructor
  alias Dashboard.Classes.Class
  alias Dashboard.Cohorts.Cohort
  alias Dashboard.Repo
  alias DashboardWeb.CalendarLive.Location

  def mapped_rows_from_locations(locations) do
    class_ids =
      locations
      |> Enum.filter(fn l -> l.model == :class end)
      |> Enum.map(fn c -> c.id end)

    cohort_ids =
      locations
      |> Enum.filter(fn l -> l.model == :cohort end)
      |> Enum.map(fn c -> c.id end)

    campus = List.first(locations).campus

    Repo.all(
      from instructor in Instructor,
        left_join: claim in Claim,
        on: claim.instructor_id == instructor.id,
        left_join: class in Class,
        on: claim.class_id == class.id and class.id in ^class_ids,
        left_join: cohort in Cohort,
        on: claim.cohort_id == cohort.id and cohort.id in ^cohort_ids,
        distinct: true,
        preload: [
          claims: [
            class: [cohort: [:campus]],
            cohort: [:campus],
            event: []
          ],
          campuses: []
        ]
    )
    |> Enum.into(%{}, fn instructor ->
      rows =
        instructor.claims
        |> Enum.map(fn claim ->
          %ClaimRow{
            claim: claim,
            event: claim.event,
            type: claim.type,
            instructor: instructor,
            location: Location.new(claim)
          }
        end)
        |> Enum.group_by(fn row ->
          row.event.id
        end)

      {instructor, rows}
    end)
    |> Enum.group_by(fn {instructor, _rows} ->
      # TODO: Support guest instructors.
      if campus in instructor.campuses do
        :local
      else
        :remote
      end
    end)
  end
end
