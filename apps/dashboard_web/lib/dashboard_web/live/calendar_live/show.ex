defmodule DashboardWeb.CalendarLive.Show do
  use DashboardWeb, :live_view

  alias Dashboard.Calendars

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    socket =
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:calendar, Calendars.get_calendar!(id))
      |> assign(:events, Calendars.list_calendar_events(id))

    {:noreply, socket}
  end

  defp page_title(:show), do: "Show Calendar"
  defp page_title(:edit), do: "Edit Calendar"
end
