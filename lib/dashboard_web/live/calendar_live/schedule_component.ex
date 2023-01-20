defmodule DashboardWeb.CalendarLive.ScheduleComponent do
  use DashboardWeb, :live_component

  alias Dashboard.Classes.{Class, Row}
  alias Dashboard.Cohorts.Cohort
  alias Dashboard.{Accounts, Calendars, Classes, Repo}
  alias DashboardWeb.CalendarLive.Location
  alias Plug.Conn.Query
  alias Timex.Duration

  @impl true
  def update(%{instructor: instructor, parent: parent, uri: uri} = assigns, socket) do
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
         |> assign(:rows_by_date, Row.from_events_by_date(events, timezone, claim_lookup))
         |> assign(:timezone, timezone)
         |> assign_schedule_info(parent, path, query)}
    end
  end

  @impl true
  def update(
        %{
          classes: classes,
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

    classes = Repo.preload(classes, :campus)

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
          |> Row.from_events_by_date(timezone)

        instructor_claims = Accounts.list_instructors_for_schedule(classes)

        # TODO: Add guests instructors.
        # claims_by_type =
        #   Enum.reduce(
        #     instructor_claims,
        #     %{local: [], remote: [], guest: []},
        #     fn %{
        #          instructor: instructor,
        #          claims_by_event: claims_by_event
        #        } = claim_info,
        #        types ->
        #       if nil in instructor.campuses do
        #         types
        #         |> Map.get_and_update(:local, fn local ->
        #           {local, [claims_info | local]}
        #         end)
        #         |> elem(1)
        #       else
        #         types
        #         |> Map.get_and_update(:remote, fn remote ->
        #           {remote, [claims_info | remote]}
        #         end)
        #         |> elem(1)
        #       end
        #     end
        #   )

        maybe_cohort =
          case Map.get(assigns, :cohort) do
            nil -> []
            cohort -> [cohort]
          end

        locations =
          Enum.map(maybe_cohort ++ classes, fn loc ->
            case loc do
              %Cohort{} = cohort -> Location.new(cohort)
              %Class{} = class -> Location.new(class)
            end
          end)

        {:ok,
         socket
         |> assign(assigns)
         |> assign(:locations, locations)
         |> assign(:rows_by_date, rows_by_date)
         |> assign(:campus, nil)
         # |> assign(:claims_by_type, claims_by_type)
         # TODO: remove
         |> assign(:instructors, instructor_claims)
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
        %{assigns: %{classes: classes}} = socket
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
     |> assign(:instructors, Accounts.list_instructors_for_schedule(classes))}
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

  defp claims_form(%{campus: nil} = assigns) do
    ~H"""
    <.form
      :let={f}
      for={:claims}
      id={"#{@claim_type}-instructors"}
      phx-change="save-claims"
      phx-submit="save-claims"
      phx-target={@myself}
    >
      <%= for %{instructor: instructor, claims_by_event: claims_by_event} <- @claims do %>
        <% event_id = @row.event.id %>
        <% c = claims_by_event[event_id] %>
        <label>
          <%= checkbox(f, "#{@claim_type}-#{instructor.id}-#{@location}-#{event_id}",
            value: c && c.claim.type == @claim_type && "#{c.location}" == "#{@location}"
          ) %>
          <%= instructor.name %>
        </label>
      <% end %>
      <noscript><%= submit("Save", phx_disable_with: "Saving...") %></noscript>
    </.form>
    """
  end

  defp claims_form(%{} = assigns) do
    ~H"""
    <.form
      :let={f}
      for={:claims}
      id={"#{@claim_type}-instructors"}
      phx-change="save-claims"
      phx-submit="save-claims"
      phx-target={@myself}
    >
      <%= for %{instructor: instructor, claims_by_event: claims_by_event} <- @claims do %>
        <% event_id = @row.event.id %>
        <% c = claims_by_event[event_id] %>
        <label>
          <%= checkbox(f, "#{@claim_type}-#{instructor.id}-#{@location}-#{event_id}",
            value: c && c.claim.type == @claim_type && "#{c.location}" == "#{@location}"
          ) %>
          <%= instructor.name %>
        </label>
      <% end %>
      <noscript><%= submit("Save", phx_disable_with: "Saving...") %></noscript>
    </.form>
    """
  end
end
