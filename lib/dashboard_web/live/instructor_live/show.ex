defmodule DashboardWeb.InstructorLive.Show do
  use DashboardWeb, :live_view
  on_mount DashboardWeb.InstructorAuth

  alias Dashboard.Accounts
  alias Dashboard.Campuses

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    instructor = Accounts.get_instructor!(id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:instructor, instructor)
     |> assign(:campuses, Campuses.list_campuses_with_connected(instructor))}
  end

  @impl true
  def handle_event(
        "save-campuses",
        %{"campuses" => classes},
        %{assigns: %{instructor: instructor}} = socket
      ) do
    Enum.map(classes, fn {name, checked} ->
      [_, raw_id] = String.split(name, "-")
      {id, ""} = Integer.parse(raw_id)
      campus = Campuses.get_campus!(id)

      connected =
        case checked do
          "true" -> true
          "false" -> false
        end

      Accounts.create_or_delete_residence(instructor, campus, connected)
    end)

    {:noreply, socket}
  end

  def handle_event(
        "save-color",
        %{"instructor" => %{"color" => color}},
        %{assigns: %{instructor: instructor}} = socket
      ) do
    {:ok, _} = Accounts.update_instructor(instructor, %{background_color: color})

    {:noreply, socket}
  end

  defp page_title(:show), do: "Show Instructor"
  defp page_title(:edit), do: "Edit Instructor"
end
