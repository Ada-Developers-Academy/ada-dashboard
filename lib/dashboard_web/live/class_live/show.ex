defmodule DashboardWeb.ClassLive.Show do
  use DashboardWeb, :live_view

  alias Dashboard.{Classes, Calendars}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id} = params, _uri, socket) do
    class = Classes.get_class!(id)
    calendars = Calendars.list_calendars_for_class(class)
    start_date = Map.get(params, "start_date")
    events = Classes.events_for_class(class, parse_start_date(start_date))

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:class, class)
     |> assign(:calendars, calendars)
     |> assign(:events, events)
     |> put_start_date(id, start_date)}
  end

  @impl true
  def handle_event(
        "save-calendars",
        %{"calendars" => calendars},
        %{assigns: %{class: class}} = socket
      ) do
    Enum.map(calendars, fn {name, checked} ->
      [_, raw_id] = String.split(name, "-")
      {id, ""} = Integer.parse(raw_id)
      calendar = Calendars.get_calendar!(id)

      connected =
        case checked do
          "true" -> true
          "false" -> false
        end

      Classes.create_or_delete_source(class, calendar, connected)
    end)

    {:noreply, socket}
  end

  defp parse_start_date(start_param) do
    {start_date, error} =
      if start_param do
        case Timex.parse(start_param, "{YYYY}-{0M}-{D}") do
          {:ok, parsed} -> {parsed, nil}
          {:error, _} -> {nil, "Invalid start_date \"#{start_param}\"!"}
        end
      else
        {Timex.now(), nil}
      end

    start_date =
      if start_date do
        start_date |> Timex.beginning_of_week() |> Timex.to_date()
      else
        nil
      end

    if start_date do
      {:ok, start_date}
    else
      {:error, error}
    end
  end

  defp put_start_date(socket, id, start_param) do
    case parse_start_date(start_param) do
      {:ok, parsed} ->
        start_date = Timex.format!(parsed, "{YYYY}-{0M}-{D}")

        # Only redirect if the user provided a valid date and it differs from the beginning of week.
        if start_param && start_date && start_date != start_param do
          socket
          |> push_redirect(to: "/classes/#{id}?start_date=#{start_date}")
        else
          socket
        end

      {:error, error} ->
        socket
        |> put_flash(:error, error)
    end
  end

  defp page_title(:show), do: "Show Class"
  defp page_title(:edit), do: "Edit Class"
end
