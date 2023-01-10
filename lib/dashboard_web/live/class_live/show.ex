defmodule DashboardWeb.ClassLive.Show do
  use DashboardWeb, :live_view

  alias Dashboard.{Classes, Calendars}
  alias DashboardWeb.CalendarLive.ScheduleComponent

  import ScheduleComponent, only: [put_schedule_info: 3]

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id} = params, uri, socket) do
    class = Classes.get_class!(id)
    calendars = Calendars.list_calendars_for_class(class)
    start_param = Map.get(params, "start_date")

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:id, id)
     |> assign(:class, class)
     |> assign(:calendars, calendars)
     |> put_schedule_info(uri, start_param)}
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

  @doc """
  Returns the parsed start date if valid, returns an error otherwise.
  """
  def get_start_date(start_param) do
    case parse_start_date(start_param) do
      {:ok, start_date} -> start_date
      {:error, _} -> nil
    end
  end

  @doc """
  Returns the parsed start date if valid, returns an error otherwise.

  Returns:
  {:ok, parsed}
  or
  {:error, message}
  """
  def parse_start_date(start_param) do
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

  defp page_title(:show), do: "Show Class"
  defp page_title(:edit), do: "Edit Class"
end
