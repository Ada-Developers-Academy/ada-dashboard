defmodule DashboardWeb.EventLive.Index do
  use DashboardWeb, :live_view

  alias Dashboard.Calendars
  alias Dashboard.Calendars.Event

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :events, list_events())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Event")
    |> assign(:event, Calendars.get_event!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Event")
    |> assign(:event, %Event{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Events")
    |> assign(:event, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    event = Calendars.get_event!(id)
    {:ok, _} = Calendars.delete_event(event)

    {:noreply, assign(socket, :events, list_events())}
  end

  defp list_events do
    Calendars.list_events()
  end
end
