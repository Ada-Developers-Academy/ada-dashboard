defmodule DashboardWeb.CohortLive.Show do
  use DashboardWeb, :live_view

  alias Dashboard.{Cohorts, Repo}
  alias DashboardWeb.CalendarLive.ScheduleComponent

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, uri, socket) do
    cohort =
      id
      |> Cohorts.get_cohort!()
      |> Repo.preload(:classes)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:cohort, Cohorts.get_cohort!(id))
     |> assign(:classes, cohort.classes)
     |> assign(:uri, uri)
     |> assign(:self, self())}
  end

  @impl true
  def handle_info({:redirect, path}, socket) do
    {:noreply,
     socket
     |> push_redirect(to: path)}
  end

  defp page_title(:show), do: "Show Cohort"
  defp page_title(:edit), do: "Edit Cohort"
end
