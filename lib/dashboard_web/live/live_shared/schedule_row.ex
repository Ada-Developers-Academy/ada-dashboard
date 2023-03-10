defmodule DashboardWeb.LiveShared.ScheduleRow do
  alias Dashboard.Accounts.Claim
  alias Dashboard.Classes.Class
  alias Dashboard.Cohorts.Cohort
  alias DashboardWeb.LiveShared.ScheduleRow

  @enforce_keys [:status, :event, :date, :start_time, :end_time]
  defstruct [
    :status,
    :event,
    :date,
    :start_time,
    :end_time,
    :conflicts,
    :claim,
    conflicting_events: []
  ]

  def from_events_by_date(events, timezone, claim_lookup \\ nil) do
    events
    |> group_sorted_by(fn e -> e.start_time end)
    |> Enum.map(fn {_start_time, [first | rest] = grouped} ->
      start_datetime = DateTime.shift_zone!(first.start_time, timezone)
      end_datetime = DateTime.shift_zone!(first.end_time, timezone)
      # TODO: Move date formatting into the view layer?
      {:ok, date} = Timex.format(start_datetime, "{WDfull} {M}/{D}")
      # {:ok, date} = DateTime.to_date(start_datetime)
      {:ok, start_time} = Timex.format(start_datetime, "{h12}:{m}")
      # {:ok, start_time} = DateTime.to_time(start_datetime)
      {:ok, end_time} = Timex.format(end_datetime, "{h12}:{m}")
      # {:ok, end_time} = DateTime.to_time(end_datetime)

      conflicts = []

      conflicts =
        if Enum.any?(rest, fn e -> e.description != first.description end) do
          ["description" | conflicts]
        else
          conflicts
        end

      conflicts =
        if Enum.any?(rest, fn e -> e.end_time != first.end_time end) do
          ["time range" | conflicts]
        else
          conflicts
        end

      conflicts =
        if Enum.any?(rest, fn e -> e.title != first.title end) do
          ["title" | conflicts]
        else
          conflicts
        end

      {status, conflicting_events} =
        if length(conflicts) > 0 do
          {:conflict, grouped}
        else
          {:ok, []}
        end

      formatted_claim =
        if claim_lookup do
          case claim_lookup[first.id] do
            %Claim{class: %Class{name: name}, type: type} ->
              "#{name} (#{type})"

            %Claim{cohort: %Cohort{} = _, type: type} ->
              "Auditorium (#{type})"
          end
        else
          nil
        end

      %ScheduleRow{
        status: status,
        event: first,
        date: date,
        start_time: start_time,
        end_time: end_time,
        conflicting_events: conflicting_events,
        conflicts: conflicts,
        claim: formatted_claim
      }
    end)
    |> group_sorted_by(fn %ScheduleRow{} = row -> row.date end)
  end

  @doc """
  Takes in a sorted list of elements and a key function, returns a list of tuples in the form of:
  [{key, [element, element...]}, ...]

  NOTE: A precondition of this is that the items must _already_ be sorted according to keyfn.
  """
  # TODO: Stick this into a util module?
  def group_sorted_by(sorted, keyfn) do
    sorted
    |> Enum.reverse()
    |> Enum.reduce([], fn item, acc ->
      key = keyfn.(item)

      case acc do
        [] -> [{key, [item]}]
        [{^key, items} | rest] -> [{key, [item | items]} | rest]
        _ -> [{key, [item]} | acc]
      end
    end)
  end
end
