defmodule DashboardWeb.CalendarLive.ScheduleComponent do
  use DashboardWeb, :live_component

  alias Dashboard.Classes.Class
  alias Dashboard.Cohorts.Cohort
  alias Dashboard.{Accounts, Calendars, Classes}
  alias DashboardWeb.CalendarLive.Location
  alias Plug.Conn.Query
  alias Timex.Duration

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

    case parse_start_date(query) do
      {:error, _} ->
        # Error reporting is handled by put_schedule_info
        {:ok,
         socket
         |> assign(assigns)
         |> put_schedule_info(parent, path, query)}

      {_, start_date} ->
        events = Classes.events_for_classes(classes, start_date)
        instructors = Accounts.list_instructors_for_schedule(classes)

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
         |> assign(:events, events)
         |> assign(:instructors, instructors)
         |> put_schedule_info(parent, path, query)}
    end
  end

  @impl true
  def handle_event(
        "save-claims",
        %{"instructors" => instructors},
        %{assigns: %{classes: classes}} = socket
      ) do
    Enum.map(instructors, fn {name, checked} ->
      [raw_type, raw_instructor, raw_location, raw_event] = String.split(name, "-")
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
    end)

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

  defp put_schedule_info(socket, parent, path, query) do
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
    end
  end
end
