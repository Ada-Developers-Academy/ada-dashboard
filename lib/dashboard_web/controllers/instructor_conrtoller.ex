defmodule DashboardWeb.InstructorController do
  use DashboardWeb, :controller

  alias Dashboard.Accounts

  def colors(conn, _params) do
    conn
    |> put_resp_content_type("text/css")
    |> put_root_layout(false)
    |> render("colors.css", pairs: Accounts.all_names_and_colors())
  end
end
