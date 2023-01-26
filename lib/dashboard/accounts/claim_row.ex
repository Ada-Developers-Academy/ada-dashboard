defmodule Dashboard.Accounts.ClaimRow do
  @enforce_keys [:event_id, :instructor_id, :location, :type]
  defstruct [
    :event_id,
    :instructor_id,
    :location,
    :type
  ]

  import Ecto.Query, warn: false

  alias Dashboard.Accounts.ClaimRow
  alias Dashboard.Accounts.Instructor
  alias Dashboard.Campuses
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

    campus_ids = Enum.map(locations, fn l -> l.campus_id end)
    campus_id = List.first(campus_ids)

    unless Enum.all?(campus_ids, fn id -> campus_id == id end) do
      raise "Not all campus ids match for these locations!"
    end

    campus = Campuses.get_campus!(campus_id)

    Repo.all(
      from instructor in Instructor,
        left_join: claim in assoc(instructor, :claims),
        left_join: class in Class,
        on: claim.class_id == class.id and class.id in ^class_ids,
        left_join: cohort in Cohort,
        on: claim.cohort_id == cohort.id and cohort.id in ^cohort_ids,
        left_join: campus in assoc(instructor, :campuses),
        left_join: claim_class in assoc(claim, :class),
        left_join: claim_cohort in assoc(claim, :cohort),
        left_join: claim_class_cohort in assoc(claim_class, :cohort),
        left_join: claim_class_cohort_campus in assoc(claim_class_cohort, :campus),
        left_join: claim_cohort_campus in assoc(claim_cohort, :campus),
        left_join: claim_event in assoc(claim, :event),
        distinct: true,
        preload: [
          campuses: campus,
          claims:
            {claim,
             [
               class:
                 {claim_class,
                  [
                    cohort: {
                      claim_class_cohort,
                      [campus: claim_class_cohort_campus]
                    }
                  ]},
               cohort: {claim_cohort, [campus: claim_cohort_campus]},
               event: claim_event
             ]}
        ]
    )
    |> Enum.filter(fn instructor ->
      is_nil(instructor.is_guest) or campus in instructor.campuses
    end)
    |> Enum.into(%{}, fn instructor ->
      rows =
        instructor.claims
        |> Enum.map(fn claim ->
          %ClaimRow{
            event_id: claim.event.id,
            instructor_id: instructor.id,
            type: claim.type,
            location: Location.new(claim)
          }
        end)
        |> Enum.group_by(fn row ->
          row.event_id
        end)

      {instructor, rows}
    end)
    |> Enum.map(fn {instructor, rows_by_event} ->
      {instructor,
       Enum.into(rows_by_event, %{}, fn {event, [row]} ->
         {event, row}
       end)}
    end)
    |> Enum.group_by(fn {instructor, _rows_by_event} ->
      cond do
        is_nil(instructor.email) ->
          :guest

        campus in instructor.campuses ->
          :local

        true ->
          :remote
      end
    end)
    |> Enum.into(%{}, fn {locality, instructors} ->
      {locality, Enum.sort_by(instructors, fn {instructor, _claims} -> instructor.name end)}
    end)
  end
end
