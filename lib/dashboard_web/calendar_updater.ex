alias Dashboard.Calendars

defmodule DashboardWeb.CalendarUpdater do
  use GenServer
  require Logger

  def start(state) do
    GenServer.start(__MODULE__, state)
  end

  @impl true
  def init(state = %{provider: provider, code: code}) do
    token = oauth_get_token!(provider, code)
    user = oauth_get_user!(provider, token).body

    seconds =
      Application.get_env(
        :dashboard,
        DashboardWeb.CalendarUpdater
      )[:interval_seconds]

    state =
      state
      |> Map.put(:interval_seconds, seconds)
      |> Map.put(:token, token)
      |> Map.put(:user, user)

    schedule_update(%{interval_seconds: 1})

    {:ok, state}
  end

  @impl true
  def handle_info(:update, state = %{provider: provider, token: token}) do
    update_calendars(provider, token)
    schedule_update(state)

    {:noreply, state}
  end

  @impl true
  def handle_call({:set_interval, seconds}, _from, state) do
    {:reply, state, Map.put(state, :interval_seconds, seconds)}
  end

  @impl true
  def handle_call(:get_user, _from, state = %{user: user}) do
    {:reply, user, state}
  end

  def set_interval(seconds) do
    GenServer.call(__MODULE__, {:set_interval, seconds})
  end

  def get_user!(pid) do
    GenServer.call(pid, :get_user)
  end

  defp update_calendars(provider, token) do
    calendars = get_calendars!(provider, token)
    get_events!(provider, token, calendars)
  end

  defp schedule_update(%{interval_seconds: seconds}) do
    Process.send_after(
      self(),
      :update,
      seconds * 1000
    )
  end

  defp get_events!("google" = provider, token, calendars) do
    event_base_url = "https://www.googleapis.com/calendar/v3/calendars"

    # TODO: Validate calendar provider matches.

    Enum.each(calendars, fn cal ->
      unless cal.external_provider == provider do
        raise ArgumentError,
              "Attempting to access calendar with provider (#{cal.external_provider}) using provider (#{provider})"
      end

      now = DateTime.now!(cal.timezone)
      days_since_monday = Date.day_of_week(now) - 1

      monday =
        now
        |> DateTime.to_date()
        |> Date.add(-1 * days_since_monday)
        |> DateTime.new!(~T[00:00:00], cal.timezone)

      monday_after_next =
        monday
        |> DateTime.to_date()
        |> Date.add(21)
        |> DateTime.new!(~T[00:00:00], cal.timezone)

      params =
        URI.encode_query(%{
          "timeMin" => monday |> DateTime.to_iso8601(),
          "timeMax" => monday_after_next |> DateTime.to_iso8601(),
          "orderBy" => "startTime",
          "singleEvents" => "true"
        })

      url =
        "#{event_base_url}/#{cal.external_id}/events"
        |> URI.parse()
        |> URI.append_query(params)
        |> URI.to_string()

      case OAuth2.Client.get(token, url) do
        {:ok, response} ->
          [
            Enum.each(response.body["items"], fn event ->
              start_time = event["start"]["dateTime"]
              end_time = event["end"]["dateTime"]

              # Ignore all day events (they don't need instructors)
              if start_time || end_time do
                Calendars.get_or_create_event!(%{
                  external_id: event["id"],
                  external_provider: provider,
                  calendar_id: cal.id,
                  location: event["location"],
                  start_time: start_time,
                  end_time: end_time,
                  title: event["summary"],
                  description: event["description"]
                })
              end
            end)
          ]

        {:error, %OAuth2.Response{} = error} ->
          error_code = error.body["error"]["code"]
          Logger.debug(error)
          Logger.info("Failed to update #{cal.name}: #{error_code}")
      end
    end)
  end

  defp get_calendars!("google" = provider, token) do
    cal_url = "https://www.googleapis.com/calendar/v3/users/me/calendarList"

    cals =
      case OAuth2.Client.get(token, cal_url) do
        {:ok, resp} ->
          resp.body["items"]

        # TODO: Handle reauthorization!
        {:error, %OAuth2.Response{status_code: code, body: body}} ->
          Logger.debug(body)
          exit("Failed to get calendars!  Status: #{code}")

        {:error, %OAuth2.Error{reason: reason}} ->
          exit("Failed to get calendars!  #{reason}")
      end

    Enum.map(cals, fn cal ->
      {:ok, cal} =
        Calendars.get_or_create_calendar(%{
          name: cal["summary"],
          external_id: cal["id"],
          external_provider: provider,
          timezone: cal["timeZone"]
        })

      cal
    end)
  end

  defp oauth_get_token!("google", code) do
    Google.get_token!(code)
  end

  defp oauth_get_token!(provider, _code) do
    raise "Provider \"#{provider}\" not supported!"
  end

  defp oauth_get_user!("google", token) do
    openid_url = "https://accounts.google.com/.well-known/openid-configuration"
    user_url = OAuth2.Client.get!(token, openid_url).body["userinfo_endpoint"]

    OAuth2.Client.get!(token, user_url)
  end
end
