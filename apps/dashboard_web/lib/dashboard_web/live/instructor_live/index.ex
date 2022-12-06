defmodule DashboardWeb.InstructorLive.Index do
  use DashboardWeb, :live_view

  alias Dashboard.Accounts
  alias Dashboard.Accounts.Instructor

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :instructors, list_instructors())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Instructor")
    |> assign(:instructor, Accounts.get_instructor!(id))
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Instructors")
    |> assign(:instructor, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    instructor = Accounts.get_instructor!(id)
    {:ok, _} = Accounts.delete_instructor(instructor)

    {:noreply, assign(socket, :instructors, list_instructors())}
  end

  defp list_instructors do
    Accounts.list_instructors()
  end
end
