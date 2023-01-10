defmodule DashboardWeb.CalendarLive.ScheduleComponent do
  use DashboardWeb, :live_component

  alias Dashboard.{Accounts, Calendars, Classes}
  alias Plug.Conn.Query

  alias Timex.Duration

  @impl true
  def update(
        %{
          classes: classes,
          schedule_start_date: start_date,
          # Required for rendering
          schedule_path_prev: _,
          schedule_path_next: _
        } = assigns,
        socket
      ) do
    events = Classes.events_for_classes(classes, start_date)
    instructors = Accounts.list_instructors_for_classes(classes)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:events, events)
     |> assign(:instructors, instructors)}
  end

  @impl true
  def handle_event(
        "save-claims",
        %{"instructors" => instructors},
        %{assigns: %{classes: classes}} = socket
      ) do
    Enum.map(instructors, fn {name, checked} ->
      [raw_type, raw_instructor, raw_event] = String.split(name, "-")
      {instructor_id, ""} = Integer.parse(raw_instructor)
      instructor = Accounts.get_instructor!(instructor_id)
      {event_id, ""} = Integer.parse(raw_event)
      event = Calendars.get_event!(event_id)

      type =
        case checked do
          "true" -> raw_type
          "false" -> nil
        end

      Accounts.create_or_delete_claim(instructor, event, type)
    end)

    {:noreply,
     socket
     |> assign(:instructors, Accounts.list_instructors_for_classes(classes))}
  end

  defp parse_start_date(start_param) do
    {start_date, error} =
      if start_param do
        case Timex.parse(start_param, "{YYYY}-{0M}-{0D}") do
          {:ok, parsed} -> {parsed, nil}
          {:error, _} -> {nil, "Invalid start_date \"#{start_param}\"!"}
        end
      else
        {Timex.now(), nil}
      end

    start_date =
      if start_date do
        start_date |> Timex.beginning_of_week()
      else
        nil
      end

    if start_date do
      {:ok, start_date}
    else
      {:error, error}
    end
  end

  @doc """
  Store :schedule_start_date, :schedule_path_prev, and :schedule_path_next in the assigns.

  Pushes a redirect to correct start_date if it isn't a Monday.
  """
  def put_schedule_info(socket, uri, start_param) do
    %URI{
      path: path,
      query: raw_query
    } = URI.parse(uri)

    query =
      case raw_query do
        nil -> %{}
        str -> Query.decode(str)
      end

    case parse_start_date(start_param) do
      {:ok, start_date} ->
        start_query =
          start_date
          |> Timex.beginning_of_week()
          |> Timex.format!("{YYYY}-{0M}-{0D}")

        new_query =
          query
          |> Map.put("start_date", start_query)
          |> Query.encode()

        # Only redirect if the user provided a valid date and it differs from the beginning of week.
        socket =
          if start_param && start_query && start_query != start_param do
            socket
            |> push_redirect(to: "#{path}?#{new_query}")
          else
            socket
          end

        prev_query =
          start_date
          |> Timex.subtract(Duration.from_weeks(1))
          |> Timex.format!("{YYYY}-{0M}-{0D}")

        next_query =
          start_date
          |> Timex.add(Duration.from_weeks(1))
          |> Timex.format!("{YYYY}-{0M}-{0D}")

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

      {:error, error} ->
        socket
        |> put_flash(:error, error)
    end
  end
end
