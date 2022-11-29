defmodule DashboardWeb.AuthController do
  use DashboardWeb, :controller

  alias Dashboard.Accounts

  def index(conn, %{"provider" => provider}) do
    redirect(conn, external: authorize_url!(provider))
  end

  def callback(conn, %{"provider" => provider, "code" => code}) do
    token = get_token!(provider, code)
    user = get_user!(provider, token).body
    {:ok, updater_pid} = DashboardWeb.CalendarUpdater.start(%{token: token, provider: provider})

    email = user["email"]

    if provider == "google" and
         String.ends_with?(email, "@adadevelopersacademy.org") do
      external_id = user["sub"]

      {:ok, _instructor} =
        Accounts.create_or_update_instructor(%{
          name: user["name"],
          email: email,
          external_provider: provider,
          external_id: external_id
        })
    end

    conn
    |> put_session(:current_user, user)
    |> put_session(:token, token)
    |> put_session(:calendar_updater_pid, updater_pid)
    |> redirect(to: "/")
  end

  def logout(conn, _params) do
    updater_pid = get_session(conn, :calendar_updater_pid)

    unless is_nil(updater_pid) do
      Process.exit(updater_pid, :logout)
    end

    conn
    |> put_flash(:info, "You have been logged out!")
    |> delete_session(:current_user)
    |> delete_session(:token)
    |> delete_session(:calendar_updater_pid)
    |> redirect(to: "/")
  end

  defp authorize_url!("google") do
    Google.authorize_url!()
  end

  defp authorize_url!(provider) do
    raise "Provider \"#{provider}\" not supported!"
  end

  defp get_token!("google", code) do
    Google.get_token!(code)
  end

  defp get_token!(provider, _code) do
    raise "Provider \"#{provider}\" not supported!"
  end

  defp get_user!("google", token) do
    openid_url = "https://accounts.google.com/.well-known/openid-configuration"
    user_url = OAuth2.Client.get!(token, openid_url).body["userinfo_endpoint"]

    OAuth2.Client.get!(token, user_url)
  end
end
