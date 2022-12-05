defmodule DashboardWeb.PageLive.Index do
  use DashboardWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    current_user = Map.get(session, "current_user")
    {:ok, assign(socket, :current_user, current_user)}
  end
end
