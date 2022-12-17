defmodule DashboardWeb.PageLive.Index do
  use DashboardWeb, :live_view

  alias Dashboard.{Accounts, Repo}

  @impl true
  def mount(_params, session, socket) do
    current_user = Map.get(session, "current_user")
    user_id = Map.get(session, "current_user_id")

    # TODO: Add support for student login.
    instructor =
      user_id
      |> Accounts.get_instructor!()
      |> Repo.preload(:classes)

    {:ok,
     socket
     |> assign(:current_user, current_user)
     |> assign(:instructor, instructor)}
  end
end
