defmodule DashboardWeb.CampusLive.FormComponent do
  use DashboardWeb, :live_component

  alias Dashboard.Campuses

  @impl true
  def update(%{campus: campus} = assigns, socket) do
    changeset = Campuses.change_campus(campus)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"campus" => campus_params}, socket) do
    changeset =
      socket.assigns.campus
      |> Campuses.change_campus(campus_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"campus" => campus_params}, socket) do
    save_campus(socket, socket.assigns.action, campus_params)
  end

  defp save_campus(socket, :edit, campus_params) do
    case Campuses.update_campus(socket.assigns.campus, campus_params) do
      {:ok, _campus} ->
        {:noreply,
         socket
         |> put_flash(:info, "Campus updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_campus(socket, :new, campus_params) do
    case Campuses.create_campus(campus_params) do
      {:ok, _campus} ->
        {:noreply,
         socket
         |> put_flash(:info, "Campus created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
