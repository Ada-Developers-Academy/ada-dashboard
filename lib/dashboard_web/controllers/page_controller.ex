defmodule DashboardWeb.PageController do
  use DashboardWeb, :controller

  def index(conn, params) do
    live_render(conn, DashboardWeb.PageLive.Index,
      session: %{
        "current_user" => get_session(conn, :current_user),
        "uri" => current_url(conn, params)
      }
    )
  end
end
