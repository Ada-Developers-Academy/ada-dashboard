defmodule DashboardWeb.LiveShared.ClaimsCellComponent do
  use DashboardWeb, :live_component

  alias Dashboard.Accounts
  alias Dashboard.Calendars
  alias DashboardWeb.LiveShared.ClaimRow
  alias DashboardWeb.LiveShared.Location

  @impl true
  def update(
        %{
          claim_rows: claim_rows,
          row: %{event: %{id: event_id}},
          claim_type: claim_type
        } = assigns,
        socket
      ) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(
       :instructor_names,
       get_instructor_names_and_handles(claim_rows, event_id, claim_type)
     )
     |> assign(:expand, false)}
  end

  @impl true
  def handle_event(
        "expand-claims",
        _assigns,
        socket
      ) do
    {:noreply, assign(socket, :expand, true)}
  end

  @impl true
  def handle_event(
        "collapse-claims",
        _assigns,
        socket
      ) do
    {:noreply, assign(socket, :expand, false)}
  end

  @impl true
  def handle_event(
        "save-claims",
        %{
          "_target" => ["claims", target],
          "claims" => claims
        },
        %{assigns: %{locations: locations}} = socket
      ) do
    checked = claims[target]

    [raw_type, raw_instructor, raw_location, raw_event] = String.split(target, "-")
    {instructor_id, ""} = Integer.parse(raw_instructor)
    instructor = Accounts.get_instructor!(instructor_id)
    location = Location.get!(raw_location)
    {event_id, ""} = Integer.parse(raw_event)
    event = Calendars.get_event!(event_id)

    type =
      case checked do
        "true" -> raw_type
        "false" -> nil
      end

    Accounts.create_or_delete_claim(instructor, location, event, type)
    claim_rows = ClaimRow.mapped_rows_from_locations(locations)

    {:noreply,
     socket
     |> assign(:claim_rows, claim_rows)
     |> assign(:instructor_names, get_instructor_names_and_handles(claim_rows, event_id, type))}
  end

  @impl true
  def handle_event(
        "add-guest-claims",
        %{"add_guest_instructor" => params},
        %{
          assigns: %{
            campus: campus,
            locations: locations,
            parent: parent
          }
        } = socket
      ) do
    [{target, name}] = Enum.to_list(params)

    [claim_type, raw_location, raw_event] = String.split(target, "-")
    location = Location.get!(raw_location)
    {event_id, ""} = Integer.parse(raw_event)
    event = Calendars.get_event!(event_id)

    case Accounts.create_guest_instructor(%{name: name}, campus, claim_type, location, event) do
      {:ok, _} ->
        {:noreply,
         socket
         |> assign(:claim_rows, ClaimRow.mapped_rows_from_locations(locations))}

      {:error, _operation, changeset, _changes_so_far} ->
        send(parent, {:flash, :error, get_errors(changeset, false)})

        {:noreply, socket}
    end
  end

  defp get_instructor_names_and_handles(claim_rows, event_id, claim_type) do
    Enum.flat_map(claim_rows, fn {_locality, instructors_with_claims} ->
      Enum.flat_map(instructors_with_claims, fn {instructor, claims_by_event} ->
        claim_row = Map.get(claims_by_event, event_id)

        if claim_row && claim_row.type == claim_type do
          handle =
            if instructor.email do
              List.first(String.split(instructor.email, "@"))
            else
              nil
            end

          [{instructor.name, handle, not is_nil(instructor.background_color)}]
        else
          []
        end
      end)
    end)
    |> Enum.sort()
  end
end
