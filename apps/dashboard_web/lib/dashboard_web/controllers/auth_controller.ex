defmodule DashboardWeb.AuthController do
  use DashboardWeb, :controller

  def index(conn, %{"provider" => provider}) do
    redirect(conn, external: authorize_url!(provider))
  end

  def callback(conn, %{"provider" => provider, "code" => code}) do
    token = get_token!(provider, code)
    # user = get_user!(provider, token)
    user = %{"name" => "fake username"}

    conn
    |> put_session(:current_user, user)
    # |> put_session(:access_token, token.access_token)
    |> redirect(to: "/")
  end

  # def delete(conn, _params) do
  #   conn
  #   |> put_flash(:info, "You have been logged out!")
  #   |> configure_session(drop: true)
  #   |> redirect(to: "/")
  # end

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
    user_url = "https://www.googleapis.com/plus/v1/people/me/openIdConnect"
    OAuth2.Client.get!(token, user_url)
  end
end
