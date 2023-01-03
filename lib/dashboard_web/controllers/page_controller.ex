defmodule DashboardWeb.PageController do
  use DashboardWeb, :controller

  def index(conn, _params) do
    conn
    |> put_session("current_user", get_session(conn, :current_user))
    |> live_render(DashboardWeb.PageLive.Index)
  end
end
