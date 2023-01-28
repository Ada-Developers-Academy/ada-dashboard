defmodule DashboardWeb.CalendarLive.ClaimsCellComponent do
  use DashboardWeb, :live_component

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:expand, true)}
  end
end
