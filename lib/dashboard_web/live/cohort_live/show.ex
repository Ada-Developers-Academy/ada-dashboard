defmodule DashboardWeb.CohortLive.Show do
  use DashboardWeb, :live_view
  on_mount DashboardWeb.InstructorAuth

  alias Dashboard.Cohorts
  alias DashboardWeb.LiveShared.ScheduleComponent

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, uri, socket) do
    # TODO: Return 404 if missing.
    cohort = Cohorts.get_with_classes_cohorts_and_campuses!(id)

    {cohort, classes} = if cohort do
      {cohort, cohort.classes}
    else
      {Cohorts.get_cohort!(id), []}
    end

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:cohort, cohort)
     |> assign(:classes, classes)
     |> assign(:uri, uri)
     |> assign(:self, self())}
  end

  defp page_title(:show), do: "Show Cohort"
  defp page_title(:edit), do: "Edit Cohort"
end
