defmodule DashboardWeb.AuthController do
  use DashboardWeb, :controller

  alias DashboardWeb.CalendarUpdater

  alias Dashboard.Accounts

  def index(conn, %{"provider" => provider}) do
    redirect(conn, external: authorize_url!(provider))
  end

  def callback(conn, %{"provider" => provider, "code" => code}) do
    {:ok, updater_pid} = CalendarUpdater.start(%{code: code, provider: provider})
    user = CalendarUpdater.get_user!(updater_pid)

    email = user["email"]

    if provider == "google" and
         String.ends_with?(email, "@adadevelopersacademy.org") do
      external_id = user["sub"]

      {:ok, instructor} =
        Accounts.create_or_update_instructor(%{
          name: user["name"],
          email: email,
          external_provider: provider,
          external_id: external_id
        })

      conn
      |> put_session(:current_user, user)
      |> put_session(:current_user_id, instructor.id)
      |> put_session(:calendar_updater_pid, updater_pid)
      |> redirect(to: "/")
    end
  end

  def logout(conn, _params) do
    updater_pid = get_session(conn, :calendar_updater_pid)

    unless is_nil(updater_pid) do
      Process.exit(updater_pid, :logout)
    end

    conn
    |> put_flash(:info, "You have been logged out!")
    |> delete_session(:current_user)
    |> delete_session(:current_instructor)
    |> delete_session(:calendar_updater_pid)
    |> redirect(to: "/")
  end

  defp authorize_url!("google") do
    Google.authorize_url!()
  end

  defp authorize_url!(provider) do
    raise "Provider \"#{provider}\" not supported!"
  end
end
