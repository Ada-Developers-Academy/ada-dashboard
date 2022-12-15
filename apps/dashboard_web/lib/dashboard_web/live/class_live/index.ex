defmodule DashboardWeb.ClassLive.Index do
  use DashboardWeb, :live_view
  on_mount DashboardWeb.InstructorAuth

  alias Dashboard.Classes
  alias Dashboard.Classes.Class

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :class_collection, list_classes())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Class")
    |> assign(:class, Classes.get_class!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Class")
    |> assign(:class, %Class{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Class")
    |> assign(:class, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    class = Classes.get_class!(id)
    {:ok, _} = Classes.delete_class(class)

    {:noreply, assign(socket, :class_collection, list_classes())}
  end

  defp list_classes do
    Classes.list_classes()
  end
end
