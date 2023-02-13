defmodule DashboardWeb.CohortLive.FormComponent do
  use DashboardWeb, :live_component

  alias Dashboard.Cohorts
  alias Dashboard.Campuses

  @impl true
  def update(%{cohort: cohort} = assigns, socket) do
    changeset = Cohorts.change_cohort(cohort)
    campuses = Enum.into(
        Campuses.list_campuses(),
        %{},
        fn c -> {c.name, c.id} end
      )

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> assign(:campuses, campuses)}
  end

  @impl true
  def handle_event("validate", %{"cohort" => cohort_params}, socket) do
    changeset =
      socket.assigns.cohort
      |> Cohorts.change_cohort(cohort_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"cohort" => cohort_params}, socket) do
    save_cohort(socket, socket.assigns.action, cohort_params)
  end

  defp save_cohort(socket, :edit, cohort_params) do
    case Cohorts.update_cohort(socket.assigns.cohort, cohort_params) do
      {:ok, _cohort} ->
        {:noreply,
         socket
         |> put_flash(:info, "Cohort updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_cohort(socket, :new, cohort_params) do
    case Cohorts.create_cohort(cohort_params) do
      {:ok, _cohort} ->
        {:noreply,
         socket
         |> put_flash(:info, "Cohort created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
