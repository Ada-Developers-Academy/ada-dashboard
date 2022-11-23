defmodule DashboardWeb.CalendarUpdater do
  use GenServer

  def start(state) do
    GenServer.start(__MODULE__, state)
  end

  @impl true
  def init(state = %{provider: provider, token: token}) do
    IO.puts("STARTING!")

    seconds =
      Application.get_env(
        :dashboard_web,
        DashboardWeb.CalendarUpdater
      )[:interval_seconds]

    state = Map.put(state, :interval_seconds, seconds)
    update_calendar(provider, token)
    schedule_update(state)

    IO.puts(
      'INITIAL ********************************************************************************'
    )

    IO.inspect(state)
    IO.puts('********************************************************************************')

    {:ok, state}
  end

  @impl true
  def handle_info(:update, state = %{provider: provider, token: token}) do
    IO.puts('********************************************************************************')
    IO.inspect(state)
    IO.puts('********************************************************************************')

    update_calendar(provider, token)
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

  defp update_calendar(provider, token) do
    get_calendars!(provider, token)
  end

  defp schedule_update(%{interval_seconds: seconds}) do
    Process.send_after(
      self(),
      :update,
      seconds * 1000
    )
  end

  defp get_calendars!("google", token) do
    cal_url = "https://www.googleapis.com/calendar/v3/users/me/calendarList"
    cals = OAuth2.Client.get!(token, cal_url).body["items"]

    Enum.map(cals, fn cal ->
      %{id: cal["id"], name: cal["summary"]}
    end)
  end
end
