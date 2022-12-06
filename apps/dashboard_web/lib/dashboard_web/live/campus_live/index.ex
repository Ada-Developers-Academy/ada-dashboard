defmodule DashboardWeb.CampusLive.Index do
  use DashboardWeb, :live_view
  on_mount DashboardWeb.InstructorAuth

  alias Dashboard.Campuses
  alias Dashboard.Campuses.Campus

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :campus_collection, list_campus())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Campus")
    |> assign(:campus, Campuses.get_campus!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Campus")
    |> assign(:campus, %Campus{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Campus")
    |> assign(:campus, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    campus = Campuses.get_campus!(id)
    {:ok, _} = Campuses.delete_campus(campus)

    {:noreply, assign(socket, :campus_collection, list_campus())}
  end

  defp list_campus do
    Campuses.list_campus()
  end
end
