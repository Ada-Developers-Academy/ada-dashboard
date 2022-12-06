defmodule DashboardWeb.InstructorAuth do
  import Phoenix.LiveView

  def on_mount(:default, _params, %{"current_user" => current_user} = _session, socket) do
    if is_nil(current_user) do
      socket =
        socket
        |> put_flash(:error, "You must be logged in as an instructor to access this page!")
        |> redirect(to: "/")

      {:halt, socket}
    else
      IO.inspect(current_user)

      {:cont, socket}
    end
  end
end
