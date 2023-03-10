defmodule DashboardWeb.ClassLive.Show do
  use DashboardWeb, :live_view
  on_mount DashboardWeb.InstructorAuth

  alias Dashboard.Calendars
  alias Dashboard.Classes
  alias DashboardWeb.LiveShared.ScheduleComponent

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, uri, socket) do
    # TODO: Return 404 if missing.
    class = Classes.get_class_with_cohort_and_campus!(id)
    calendars = Calendars.list_calendars_for_class(class)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:id, id)
     |> assign(:class, class)
     |> assign(:calendars, calendars)
     |> assign(:uri, uri)
     |> assign(:self, self())}
  end

  @impl true
  def handle_event(
        "save-calendars",
        %{"calendars" => calendars},
        %{assigns: %{class: class}} = socket
      ) do
    Enum.map(calendars, fn {name, checked} ->
      [_, raw_id] = String.split(name, "-")
      {id, ""} = Integer.parse(raw_id)
      calendar = Calendars.get_calendar!(id)

      connected =
        case checked do
          "true" -> true
          "false" -> false
        end

      Classes.create_or_delete_source(class, calendar, connected)
    end)

    {:noreply, socket}
  end

  defp page_title(:show), do: "Show Class"
  defp page_title(:edit), do: "Edit Class"
end
