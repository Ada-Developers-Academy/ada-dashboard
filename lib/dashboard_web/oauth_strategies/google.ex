defmodule Google do
  @moduledoc """
  An OAuth2 strategy for Google.
  """

  use OAuth2.Strategy

  alias OAuth2.Strategy.AuthCode

  def client() do
    OAuth2.Client.new(
      strategy: __MODULE__,
      client_id: System.get_env("GOOGLE_CLIENT_ID"),
      client_secret: System.get_env("GOOGLE_CLIENT_SECRET"),
      redirect_uri: System.get_env("REDIRECT_URI"),
      site: "https://accounts.google.com",
      authorize_url: "/o/oauth2/auth",
      token_url: "/o/oauth2/token"
    )
    |> OAuth2.Client.put_serializer("application/json", Jason)
  end

  def authorize_url! do
    OAuth2.Client.authorize_url!(
      client(),
      scope: "openid profile email https://www.googleapis.com/auth/calendar"
    )
  end

  def get_token!(code) do
    {:ok, token} = OAuth2.Client.get_token(client(), code: code)

    token
  end

  # Strategy Callbacks
  def authorize_url(client, params) do
    AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> put_header("accept", "application/json")
    |> AuthCode.get_token(params, headers)
  end
end
