defmodule DashboardWeb.PageLive.Index do
  use DashboardWeb, :live_view

  alias Dashboard.Accounts
  alias DashboardWeb.LiveShared.ScheduleComponent

  @impl true
  def mount(_params, session, socket) do
    current_user = Map.get(session, "current_user")
    user_id = Map.get(session, "current_user_id")
    uri = Map.get(session, "uri")

    # TODO: Add support for student login.
    instructor =
      if user_id do
        Accounts.get_instructor_with_campuses!(user_id)
      end

    {:ok,
     socket
     |> assign(:current_user, current_user)
     |> assign(:instructor, instructor)
     |> assign(:uri, uri)
     |> assign(:self, self())}
  end
end
