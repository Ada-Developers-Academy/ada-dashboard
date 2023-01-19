defmodule DashboardWeb.InstructorAuth do
  import Phoenix.LiveView

  def on_mount(:default, _params, %{"current_user" => _current_user} = _session, socket) do
    {:cont, socket}
  end

  def on_mount(:default, _params, _session, socket) do
    socket =
      socket
      |> put_flash(:error, "You must be logged in as an instructor to access this page!")
      |> redirect(to: "/")

    {:halt, socket}
  end
end
