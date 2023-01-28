defmodule DashboardWeb.CalendarLive.ScheduleComponent do
  use DashboardWeb, :live_component

  alias Dashboard.Accounts
  alias Dashboard.Accounts.ClaimRow
  alias Dashboard.Calendars
  alias Dashboard.Campuses.Campus
  alias Dashboard.Classes
  alias Dashboard.Classes.Class
  alias Dashboard.Classes.ScheduleRow
  alias Dashboard.Cohorts.Cohort
  alias DashboardWeb.CalendarLive.ClaimsCellComponent
  alias DashboardWeb.CalendarLive.Location
  alias Plug.Conn.Query
  alias Timex.Duration

  @impl true
  def update(
        %{
          instructor: instructor,
          parent: parent,
          uri: uri
        } = assigns,
        socket
      ) do
    %URI{
      path: path,
      query: raw_query
    } = URI.parse(uri)

    query =
      case raw_query do
        nil -> %{}
        str -> Query.decode(str)
      end

    # TODO: Configure timezone per instructor.
    timezone = "America/Los_Angeles"

    case parse_start_date(query) do
      {:error, _} ->
        # Error reporting is handled by assign_schedule_info
        {:ok,
         socket
         |> assign(assigns)
         |> assign_schedule_info(parent, path, query)}

      {_, start_date} ->
        {events, claim_lookup} = Classes.events_for_instructor(instructor, start_date)

        {:ok,
         socket
         |> assign(assigns)
         |> assign(:locations, [])
         |> assign(:rows_by_date, ScheduleRow.from_events_by_date(events, timezone, claim_lookup))
         |> assign(:timezone, timezone)
         |> assign_schedule_info(parent, path, query)}
    end
  end

  @impl true
  def update(
        %{
          classes: [%Class{cohort: %Cohort{campus: %Campus{} = campus}} | _] = classes,
          parent: parent,
          uri: uri
        } = assigns,
        socket
      ) do
    %URI{
      path: path,
      query: raw_query
    } = URI.parse(uri)

    query =
      case raw_query do
        nil -> %{}
        str -> Query.decode(str)
      end

    # TODO: Configure timezone per instructor.
    timezone = "America/Los_Angeles"

    case parse_start_date(query) do
      {:error, _} ->
        # Error reporting is handled by assign_schedule_info
        {:ok,
         socket
         |> assign(assigns)
         |> assign_schedule_info(parent, path, query)}

      {_, start_date} ->
        # TODO: Configure timezone per class.
        rows_by_date =
          Classes.events_for_classes(classes, start_date)
          |> ScheduleRow.from_events_by_date(timezone)

        maybe_cohort =
          case Map.get(assigns, :cohort) do
            nil -> []
            cohort -> [cohort]
          end

        unless Enum.all?(classes, fn c -> c.cohort.campus == campus end) do
          raise "Not all campus ids match for these classes!"
        end

        locations =
          Enum.map(maybe_cohort ++ classes, fn loc ->
            case loc do
              %Cohort{} = cohort -> Location.new(cohort)
              %Class{} = class -> Location.new(class)
            end
          end)

        claim_rows = ClaimRow.mapped_rows_from_locations(locations)

        {:ok,
         socket
         |> assign(assigns)
         |> assign(:locations, locations)
         |> assign(:rows_by_date, rows_by_date)
         |> assign(:campus, campus)
         |> assign(:claim_rows, claim_rows)
         |> assign(:timezone, timezone)
         |> assign(:instructor, nil)
         |> assign_schedule_info(parent, path, query)}
    end
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

    {:noreply,
     socket
     |> assign(:claim_rows, ClaimRow.mapped_rows_from_locations(locations))}
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

  defp parse_start_date(query) do
    case Map.get(query, "start_date") do
      nil ->
        {:default, Timex.now() |> Timex.beginning_of_week()}

      start_param ->
        case Timex.parse(start_param, "{YYYY}-{0M}-{0D}") do
          {:ok, parsed} -> {:ok, parsed}
          {:error, _} -> {:error, "Invalid start_date \"#{start_param}\"!"}
        end
    end
  end

  defp assign_schedule_info(socket, parent, path, query) do
    case parse_start_date(query) do
      {:error, error} ->
        socket
        |> put_flash(:error, error)

      {status, start_date} ->
        prev_query =
          start_date
          |> Timex.subtract(Duration.from_weeks(1))
          |> Timex.format!("{YYYY}-{0M}-{0D}")

        next_query =
          start_date
          |> Timex.add(Duration.from_weeks(1))
          |> Timex.format!("{YYYY}-{0M}-{0D}")

        today_query =
          Timex.now()
          |> Timex.beginning_of_week()
          |> Timex.format!("{YYYY}-{0M}-{0D}")

        if status != :default do
          redirect_date =
            start_date
            |> Timex.beginning_of_week()

          # Only redirect if the user provided a valid date and it differs from the beginning of week.
          if start_date != redirect_date do
            redirect_query =
              Map.put(
                query,
                "start_date",
                Timex.format!(redirect_date, "{YYYY}-{0M}-{0D}")
              )

            send(parent, {:redirect, "#{path}?#{Query.encode(redirect_query)}"})
          end
        end

        socket
        |> assign(
          :schedule_start_date,
          start_date
        )
        |> assign(
          :schedule_path_prev,
          "#{path}?start_date=#{prev_query}"
        )
        |> assign(
          :schedule_path_next,
          "#{path}?start_date=#{next_query}"
        )
        |> assign(
          :schedule_path_today,
          "#{path}?start_date=#{today_query}"
        )
    end
  end

  defp claims_form(%{} = assigns) do
    ~H"""
    <section class="claim-rows">
      <.form
        :let={f}
        for={:claims}
        phx-change="save-claims"
        phx-submit="save-claims"
        phx-target={@myself}
      >
        <%= if @claim_rows[:local] do %>
          <h3><%= @campus.name %> Instructors</h3>
          <%= for {instructor, rows_by_event} <- @claim_rows[:local] do %>
            <% claim_row = Map.get(rows_by_event, @row.event.id) %>
            <label>
              <%= checkbox(f, "#{@claim_type}-#{instructor.id}-#{@location}-#{@row.event.id}",
                value:
                  claim_row && claim_row.type == @claim_type &&
                    "#{claim_row.location}" == "#{@location}"
              ) %>
              <%= instructor.name %>
            </label>
          <% end %>
        <% end %>
        <%= if @claim_rows[:remote] do %>
          <h3>Other Instructors</h3>
          <%= for {instructor, rows_by_event} <- @claim_rows[:remote] do %>
            <% claim_row = Map.get(rows_by_event, @row.event.id) %>
            <label>
              <%= checkbox(f, "#{@claim_type}-#{instructor.id}-#{@location}-#{@row.event.id}",
                value:
                  claim_row && claim_row.type == @claim_type &&
                    "#{claim_row.location}" == "#{@location}"
              ) %>
              <%= instructor.name %>
            </label>
          <% end %>
        <% end %>
        <%= if @claim_rows[:guest] do %>
          <h3>Guest Instructors</h3>
          <%= for {instructor, rows_by_event} <- @claim_rows[:guest] do %>
            <% claim_row = Map.get(rows_by_event, @row.event.id) %>
            <label>
              <%= checkbox(f, "#{@claim_type}-#{instructor.id}-#{@location}-#{@row.event.id}",
                value:
                  claim_row && claim_row.type == @claim_type &&
                    "#{claim_row.location}" == "#{@location}"
              ) %>
              <%= instructor.name %>
            </label>
          <% end %>
        <% end %>
        <noscript><%= submit("Save", phx_disable_with: "Saving...") %></noscript>
      </.form>
      <.form
        :let={f}
        for={:add_guest_instructor}
        id={"add-#{@claim_type}-guest-instructors"}
        phx-submit="add-guest-claims"
        phx-target={@myself}
      >
        <label>
          Add guest: <%= text_input(f, "#{@claim_type}-#{@location}-#{@row.event.id}") %>
        </label>
        <%= submit("Add", phx_disable_with: "Adding...") %>
      </.form>
    </section>
    """
  end
end
