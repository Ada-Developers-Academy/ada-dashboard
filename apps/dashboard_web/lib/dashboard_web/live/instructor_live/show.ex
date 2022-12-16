defmodule DashboardWeb.InstructorLive.Show do
  use DashboardWeb, :live_view

  alias Dashboard.Accounts
  alias Dashboard.{Campuses, Classes}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    instructor = Accounts.get_instructor!(id)

    campuses =
      Enum.map(Campuses.list_campuses_with_classes(), fn campus ->
        %{
          name: campus.name,
          classes:
            Enum.map(campus.classes, fn class ->
              %{
                id: class.id,
                name: class.name,
                connected: Accounts.has_affinity(instructor, class)
              }
            end)
        }
      end)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:instructor, instructor)
     |> assign(:campuses, campuses)}
  end

  @impl true
  def handle_event(
        "save-classes",
        %{"classes" => classes},
        %{assigns: %{instructor: instructor}} = socket
      ) do
    Enum.map(classes, fn {name, checked} ->
      [_, raw_id] = String.split(name, "-")
      {id, ""} = Integer.parse(raw_id)
      class = Classes.get_class!(id)

      connected =
        case checked do
          "true" -> true
          "false" -> false
        end

      Accounts.create_or_delete_affinity(instructor, class, connected)
    end)

    {:noreply, socket}
  end

  defp page_title(:show), do: "Show Instructor"
  defp page_title(:edit), do: "Edit Instructor"
end
