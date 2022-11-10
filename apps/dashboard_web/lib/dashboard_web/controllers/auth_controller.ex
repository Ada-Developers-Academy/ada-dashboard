defmodule DashboardWeb.AuthController do
  use DashboardWeb, :controller

  alias Dashboard.Accounts.Instructor
  alias Dashboard.Accounts

  def index(conn, %{"provider" => provider}) do
    redirect(conn, external: authorize_url!(provider))
  end

  def callback(conn, %{"provider" => provider, "code" => code}) do
    token = get_token!(provider, code)
    user = get_user!(provider, token).body
    IO.inspect(conn |> get_calendars!(provider))

    email = user["email"]

    if provider == "google" and
         String.ends_with?(email, "@adadevelopersacademy.org") do
      external_id = user["sub"]

      instructor =
        Accounts.get_instructor_by_external_id(
          provider,
          external_id
        )

      if is_nil(instructor) do
        Accounts.create_instructor!(%{
          name: user["name"],
          email: email,
          external_provider: provider,
          external_id: external_id
        })
      end
    end

    conn
    |> put_session(:current_user, user)
    |> put_session(:token, token)
    |> redirect(to: "/")
  end

  def logout(conn, _params) do
    conn
    |> put_flash(:info, "You have been logged out!")
    |> delete_session(:current_user)
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

  # TODO: Move to its own module
  defp get_calendars!(conn, "google") do
    token = get_session(conn, "token")

    cal_url = "https://www.googleapis.com/calendar/v3/users/me/calendarList"
    cals = OAuth2.Client.get!(token, cal_url).body["items"]

    Enum.map(cals, fn cal ->
      %{id: cal["id"], name: cal["summary"]}
    end)
  end
end
