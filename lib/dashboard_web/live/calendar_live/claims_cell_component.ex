defmodule DashboardWeb.CalendarLive.ClaimsCellComponent do
  use DashboardWeb, :live_component

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
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
end
