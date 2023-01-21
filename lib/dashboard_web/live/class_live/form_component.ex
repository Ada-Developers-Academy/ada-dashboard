defmodule DashboardWeb.ClassLive.FormComponent do
  use DashboardWeb, :live_component

  alias Dashboard.Classes
  alias Dashboard.Campuses
  alias Dashboard.Cohorts

  @impl true
  def update(%{class: class} = assigns, socket) do
    changeset = Classes.change_class(class)

    cohort_names =
      Enum.into(
        Cohorts.list_cohorts(),
        %{},
        fn c -> {c.name, c.id} end
      )

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:cohorts, cohort_names)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"class" => class_params}, socket) do
    changeset =
      socket.assigns.class
      |> Classes.change_class(class_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"class" => class_params}, socket) do
    save_class(socket, socket.assigns.action, class_params)
  end

  defp save_class(socket, :edit, class_params) do
    case Classes.update_class(socket.assigns.class, class_params) do
      {:ok, _class} ->
        {:noreply,
         socket
         |> put_flash(:info, "Class updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_class(socket, :new, class_params) do
    case Classes.create_class(class_params) do
      {:ok, _class} ->
        {:noreply,
         socket
         |> put_flash(:info, "Class created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
