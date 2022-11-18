defmodule DashboardWeb.CalendarUpdater do
  use GenServer

  def start(state) do
    GenServer.start(__MODULE__, state)
  end

  @impl true
  def init(state = %{provider: provider, token: token}) do
    update_calendar(provider, token)
    schedule_update()

    {:ok, state}
  end

  @impl true
  def handle_info(:update, state = %{provider: provider, token: token}) do
    update_calendar(provider, token)
    schedule_update()

    {:noreply, state}
  end

  defp update_calendar(provider, token) do
    get_calendars!(provider, token)
  end

  defp schedule_update() do
    seconds =
      Application.get_env(
        :dashboard_web,
        DashboardWeb.CalendarUpdater
      )[:interval_seconds]

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
