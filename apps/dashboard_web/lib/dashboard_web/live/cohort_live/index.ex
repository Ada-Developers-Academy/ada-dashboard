defmodule DashboardWeb.CohortLive.Index do
  use DashboardWeb, :live_view

  alias Dashboard.Cohorts
  alias Dashboard.Cohorts.Cohort

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :cohort_collection, list_cohort())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Cohort")
    |> assign(:cohort, Cohorts.get_cohort!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Cohort")
    |> assign(:cohort, %Cohort{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Cohort")
    |> assign(:cohort, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    cohort = Cohorts.get_cohort!(id)
    {:ok, _} = Cohorts.delete_cohort(cohort)

    {:noreply, assign(socket, :cohort_collection, list_cohort())}
  end

  defp list_cohort do
    Cohorts.list_cohort()
  end
end
