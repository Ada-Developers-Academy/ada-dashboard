defmodule DashboardWeb.LiveShared.ScheduleComponent do
  use DashboardWeb, :live_component

  alias Dashboard.Campuses.Campus
  alias Dashboard.Classes
  alias Dashboard.Classes.Class
  alias Dashboard.Cohorts.Cohort
  alias DashboardWeb.LiveShared.ClaimRow
  alias DashboardWeb.LiveShared.ClaimsCellComponent
  alias DashboardWeb.LiveShared.Location
  alias DashboardWeb.LiveShared.ScheduleRow
  alias Plug.Conn.Query
  alias Timex.Duration

  @impl true
  def update(
        %{
          instructor: instructor,
          parent: parent,
          uri: uri
        } = assigns,
        socket
      ) do
    %URI{
      path: path,
      query: raw_query
    } = URI.parse(uri)

    query =
      case raw_query do
        nil -> %{}
        str -> Query.decode(str)
      end

    # TODO: Configure timezone per instructor.
    timezone = "America/Los_Angeles"

    case parse_start_date(query) do
      {:error, _} ->
        # Error reporting is handled by assign_schedule_info
        {:ok,
         socket
         |> assign(assigns)
         |> assign_schedule_info(parent, path, query)}

      {_, start_date} ->
        {events, claim_lookup} = Classes.events_for_instructor(instructor, start_date)

        {:ok,
         socket
         |> assign(assigns)
         |> assign(:locations, [])
         |> assign(:rows_by_date, ScheduleRow.from_events_by_date(events, timezone, claim_lookup))
         |> assign(:timezone, timezone)
         |> assign_schedule_info(parent, path, query)}
    end
  end

  @impl true
  def update(
        %{
          classes: [%Class{cohort: %Cohort{campus: %Campus{} = campus}} | _] = classes,
          parent: parent,
          uri: uri
        } = assigns,
        socket
      ) do
    %URI{
      path: path,
      query: raw_query
    } = URI.parse(uri)

    query =
      case raw_query do
        nil -> %{}
        str -> Query.decode(str)
      end

    # TODO: Configure timezone per instructor.
    timezone = "America/Los_Angeles"

    case parse_start_date(query) do
      {:error, _} ->
        # Error reporting is handled by assign_schedule_info
        {:ok,
         socket
         |> assign(assigns)
         |> assign_schedule_info(parent, path, query)}

      {_, start_date} ->
        # TODO: Configure timezone per class.
        rows_by_date =
          Classes.events_for_classes(classes, start_date)
          |> ScheduleRow.from_events_by_date(timezone)

        maybe_cohort =
          case Map.get(assigns, :cohort) do
            nil -> []
            cohort -> [cohort]
          end

        unless Enum.all?(classes, fn c -> c.cohort.campus == campus end) do
          raise "Not all campus ids match for these classes!"
        end

        locations =
          Enum.map(maybe_cohort ++ classes, fn loc ->
            case loc do
              %Cohort{} = cohort -> Location.new(cohort)
              %Class{} = class -> Location.new(class)
            end
          end)

        claim_rows = ClaimRow.mapped_rows_from_locations(locations)

        {:ok,
         socket
         |> assign(assigns)
         |> assign(:locations, locations)
         |> assign(:rows_by_date, rows_by_date)
         |> assign(:campus, campus)
         |> assign(:claim_rows, claim_rows)
         |> assign(:timezone, timezone)
         |> assign(:instructor, nil)
         |> assign_schedule_info(parent, path, query)}
    end
  end

  defp parse_start_date(query) do
    case Map.get(query, "start_date") do
      nil ->
        {:default, Timex.now() |> Timex.beginning_of_week()}

      start_param ->
        case Timex.parse(start_param, "{YYYY}-{0M}-{0D}") do
          {:ok, parsed} -> {:ok, parsed}
          {:error, _} -> {:error, "Invalid start_date \"#{start_param}\"!"}
        end
    end
  end

  defp assign_schedule_info(socket, parent, path, query) do
    case parse_start_date(query) do
      {:error, error} ->
        socket
        |> put_flash(:error, error)

      {status, start_date} ->
        prev_query =
          start_date
          |> Timex.subtract(Duration.from_weeks(1))
          |> Timex.format!("{YYYY}-{0M}-{0D}")

        next_query =
          start_date
          |> Timex.add(Duration.from_weeks(1))
          |> Timex.format!("{YYYY}-{0M}-{0D}")

        today_query =
          Timex.now()
          |> Timex.beginning_of_week()
          |> Timex.format!("{YYYY}-{0M}-{0D}")

        if status != :default do
          redirect_date =
            start_date
            |> Timex.beginning_of_week()

          # Only redirect if the user provided a valid date and it differs from the beginning of week.
          if start_date != redirect_date do
            redirect_query =
              Map.put(
                query,
                "start_date",
                Timex.format!(redirect_date, "{YYYY}-{0M}-{0D}")
              )

            send(parent, {:redirect, "#{path}?#{Query.encode(redirect_query)}"})
          end
        end

        socket
        |> assign(
          :schedule_start_date,
          start_date
        )
        |> assign(
          :schedule_path_prev,
          "#{path}?start_date=#{prev_query}"
        )
        |> assign(
          :schedule_path_next,
          "#{path}?start_date=#{next_query}"
        )
        |> assign(
          :schedule_path_today,
          "#{path}?start_date=#{today_query}"
        )
    end
  end
end
