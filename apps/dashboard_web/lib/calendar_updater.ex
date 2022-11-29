alias Dashboard.Calendars

defmodule DashboardWeb.CalendarUpdater do
  use GenServer
  require Logger

  def start(state) do
    GenServer.start(__MODULE__, state)
  end

  @impl true
  def init(state = %{provider: provider, token: token}) do
    seconds =
      Application.get_env(
        :dashboard_web,
        DashboardWeb.CalendarUpdater
      )[:interval_seconds]

    state = Map.put(state, :interval_seconds, seconds)
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

  def set_interval(seconds) do
    GenServer.call(__MODULE__, {:set_interval, seconds})
  end

  defp update_calendars(provider, token) do
    calendars = get_calendars!(provider, token)
    IO.inspect(get_events!(provider, token, calendars))
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

    Enum.flat_map(calendars, fn cal ->
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
          "timeMax" => monday_after_next |> DateTime.to_iso8601()
        })

      url =
        "#{event_base_url}/#{cal.external_id}/events"
        |> URI.parse()
        |> URI.append_query(params)
        |> URI.to_string()

      case OAuth2.Client.get(token, url) do
        {:ok, events} ->
          [events]

        {:error, %OAuth2.Response{} = error} ->
          error_code = error.body["error"]["code"]
          Logger.info("Failed to update #{cal.name}: #{error_code}")

          []
      end
    end)
  end

  defp get_calendars!("google" = provider, token) do
    cal_url = "https://www.googleapis.com/calendar/v3/users/me/calendarList"
    cals = OAuth2.Client.get!(token, cal_url).body["items"]

    Enum.map(cals, fn cal ->
      {:ok, cal} =
        Calendars.create_or_update_calendar(%{
          name: cal["summary"],
          external_id: cal["id"],
          external_provider: provider,
          timezone: cal["timeZone"]
        })

      cal
    end)
  end
end
