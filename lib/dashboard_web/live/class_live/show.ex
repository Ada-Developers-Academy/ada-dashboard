defmodule DashboardWeb.ClassLive.Show do
  use DashboardWeb, :live_view

  alias Dashboard.{Classes, Calendars}

  alias Timex.Duration

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id} = params, _uri, socket) do
    class = Classes.get_class!(id)
    calendars = Calendars.list_calendars_for_class(class)
    start_param = Map.get(params, "start_date")

    {start_date, end_date} =
      case parse_start_date(start_param) do
        {:ok, start_date} -> {start_date, Timex.end_of_week(start_date)}
        {:error, _} -> {nil, nil}
      end

    events = Classes.events_for_class(class, start_date, end_date)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:id, id)
     |> assign(:class, class)
     |> assign(:calendars, calendars)
     |> assign(:events, events)
     |> put_start_date(id, start_param)}
  end

  @impl true
  def handle_event(
        "save-calendars",
        %{"calendars" => calendars},
        %{assigns: %{class: class}} = socket
      ) do
    Enum.map(calendars, fn {name, checked} ->
      [_, raw_id] = String.split(name, "-")
      {id, ""} = Integer.parse(raw_id)
      calendar = Calendars.get_calendar!(id)

      connected =
        case checked do
          "true" -> true
          "false" -> false
        end

      Classes.create_or_delete_source(class, calendar, connected)
    end)

    {:noreply, socket}
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

  defp put_start_date(socket, id, start_param) do
    case parse_start_date(start_param) do
      {:ok, start_date} ->
        start_query = Timex.format!(start_date, "{YYYY}-{0M}-{0D}")

        # Only redirect if the user provided a valid date and it differs from the beginning of week.
        socket =
          if start_param && start_query && start_query != start_param do
            socket
            |> push_redirect(to: "/classes/#{id}?start_date=#{start_query}")
          else
            socket
          end

        socket
        |> assign(
          :prev_start_query,
          start_date
          |> Timex.subtract(Duration.from_weeks(1))
          |> Timex.format!("{YYYY}-{0M}-{0D}")
        )
        |> assign(
          :next_start_query,
          start_date
          |> Timex.add(Duration.from_weeks(1))
          |> Timex.format!("{YYYY}-{0M}-{0D}")
        )

      {:error, error} ->
        socket
        |> put_flash(:error, error)
    end
  end

  defp page_title(:show), do: "Show Class"
  defp page_title(:edit), do: "Edit Class"
end
