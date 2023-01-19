defmodule DashboardWeb.CampusLive.Show do
  use DashboardWeb, :live_view
  on_mount DashboardWeb.InstructorAuth

  alias Dashboard.Campuses

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:campus, Campuses.get_campus!(id))}
  end

  defp page_title(:show), do: "Show Campus"
  defp page_title(:edit), do: "Edit Campus"
end
