defmodule DashboardWeb.ClassLive.Show do
  use DashboardWeb, :live_view

  alias Dashboard.{Calendars, Classes}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    class = Classes.get_class!(id)

    calendars =
      Enum.map(Calendars.list_calendars(), fn calendar ->
        %{
          id: calendar.id,
          name: calendar.name,
          connected: Calendars.has_class_calendar(class, calendar)
        }
      end)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:class, class)
     |> assign(:calendars, calendars)}
  end

  @impl true
  def handle_event(
        "save-calendars",
        %{"calendars" => calendars},
        %{assigns: %{class: class}} = socket
      ) do
    calendars =
      Enum.map(calendars, fn {name, checked} ->
        [_, raw_id] = String.split(name, "-")
        {id, ""} = Integer.parse(raw_id)
        calendar = Calendars.get_calendar!(id)

        connected =
          case checked do
            "true" -> true
            "false" -> false
          end

        Calendars.create_or_delete_class_calendar(class, calendar, connected)

        %{calendar: calendar, connected: connected}
      end)

    IO.puts("********************************************************************************")
    IO.inspect(calendars)
    IO.puts("********************************************************************************")

    {:noreply, socket}
  end

  defp page_title(:show), do: "Show Class"
  defp page_title(:edit), do: "Edit Class"
end
