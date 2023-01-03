defmodule DashboardWeb.CohortLive.Show do
  use DashboardWeb, :live_view

  alias Dashboard.Cohorts

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:cohort, Cohorts.get_cohort!(id))}
  end

  defp page_title(:show), do: "Show Cohort"
  defp page_title(:edit), do: "Edit Cohort"
end
