defmodule DashboardWeb.PageController do
  use DashboardWeb, :controller

  def index(conn, _params) do
    current_user = get_session(conn, :current_user)

    conn
    |> assign(:current_user, current_user)
    |> assign(:page_title, "Home")
    |> live_render(
      DashboardWeb.PageLive.Index,
      session: %{"current_user" => current_user}
    )
  end
end
