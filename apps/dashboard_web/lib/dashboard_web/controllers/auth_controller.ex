defmodule DashboardWeb.AuthController do
  use DashboardWeb, :controller

  alias Dashboard.Accounts.Instructor
  alias Dashboard.Accounts

  def index(conn, %{"provider" => provider}) do
    redirect(conn, external: authorize_url!(provider))
  end

  def callback(conn, %{"provider" => provider, "code" => code}) do
    token = get_token!(provider, code)
    %OAuth2.Response{body: user} = get_user!(provider, token)

    email = user["email"]

    if provider == "google" and
         String.ends_with?(email, "@adadevelopersacademy.org") do
      external_id = user["sub"]

      instructor =
        Accounts.get_instructor_by_external_id(
          provider,
          external_id
        )

      IO.inspect(instructor)

      if is_nil(instructor) do
        IO.puts("INSIDE IF!")

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
    |> put_session(:access_token, token.token.access_token)
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
    # TODO: Fetch from https://accounts.google.com/.well-known/openid-configuration
    user_url = "https://openidconnect.googleapis.com/v1/userinfo"
    OAuth2.Client.get!(token, user_url)
  end
end
