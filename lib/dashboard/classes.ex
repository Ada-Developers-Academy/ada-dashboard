defmodule Dashboard.Classes do
  @moduledoc """
  The Classes context.
  """

  import Ecto.Query, warn: false
  alias Dashboard.Repo
  alias Dashboard.Calendars.{Calendar, Event}
  alias Dashboard.Classes.{Class, Source, Row}

  @doc """
  Returns the list of classes.

  ## Examples

  iex> list_classes()
  [%Class{}, ...]

  """
  def list_classes do
    Repo.all(Class)
  end

  @doc """
  Gets a single class.

  Raises `Ecto.NoResultsError` if the Class does not exist.

  ## Examples

  iex> get_class!(123)
  %Class{}

  iex> get_class!(456)
  ** (Ecto.NoResultsError)

  """
  def get_class!(id), do: Repo.get!(Class, id)

  @doc """
  Creates a class.

  ## Examples

  iex> create_class(%{field: value})
  {:ok, %Class{}}

  iex> create_class(%{field: bad_value})
  {:error, %Ecto.Changeset{}}

  """
  def create_class(attrs \\ %{}) do
    %Class{}
    |> Class.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a class.

  ## Examples

  iex> update_class(class, %{field: new_value})
  {:ok, %Class{}}

  iex> update_class(class, %{field: bad_value})
  {:error, %Ecto.Changeset{}}

  """
  def update_class(%Class{} = class, attrs) do
    class
    |> Class.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a class.

  ## Examples

  iex> delete_class(class)
  {:ok, %Class{}}

  iex> delete_class(class)
  {:error, %Ecto.Changeset{}}

  """
  def delete_class(%Class{} = class) do
    Repo.delete(class)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking class changes.

  ## Examples

  iex> change_class(class)
  %Ecto.Changeset{data: %Class{}}

  """
  def change_class(%Class{} = class, attrs \\ %{}) do
    Class.changeset(class, attrs)
  end

  @doc """
  Ensure the connection exists if connected is true, and that it doesn't otherwise.
  """
  def create_or_delete_source(class, calendar, connected) do
    Repo.transaction(fn ->
      source = Repo.get_by(Source, class_id: class.id, calendar_id: calendar.id)

      case {source, connected} do
        {nil, true} ->
          source = %Source{class_id: class.id, calendar_id: calendar.id}
          Repo.insert!(source)

        {nil, false} ->
          nil

        {source, false} ->
          Repo.delete!(source)
      end
    end)
  end

  @doc """
  Returns all events for a given class.
  """
  def events_for_classes(_classes, nil), do: nil

  def events_for_classes(classes, start_date) do
    end_time = Timex.end_of_week(start_date)
    class_ids = Enum.map(classes, fn c -> c.id end)

    # TODO: Configure timezone per class.
    Repo.all(
      from e in Event,
        join: c in Calendar,
        on: e.calendar_id == c.id,
        join: s in Source,
        on: s.calendar_id == c.id,
        where:
          s.class_id in ^class_ids and ^start_date <= e.start_time and e.end_time <= ^end_time,
        order_by: e.start_time,
        preload: :calendar
    )
    |> group_sorted_by(fn e -> e.start_time end)
    |> Enum.flat_map(fn {start_time_utc, [first | rest] = events} ->
      start_datetime = DateTime.shift_zone!(start_time_utc, "America/Los_Angeles")
      end_datetime = DateTime.shift_zone!(first.end_time, "America/Los_Angeles")
      # TODO: Move date formatting into the view layer?
      {:ok, date} = Timex.format(start_datetime, "{WDfull} {M}/{D}")
      # {:ok, date} = DateTime.to_date(start_datetime)
      {:ok, start_time} = Timex.format(start_datetime, "{h12}:{m}")
      # {:ok, start_time} = DateTime.to_time(start_datetime)
      {:ok, end_time} = Timex.format(end_datetime, "{h12}:{m}")
      # {:ok, end_time} = DateTime.to_time(end_datetime)

      status =
        if Enum.any?(rest, fn e ->
             e.end_time != first.end_time or e.title != first.title or
               e.description != first.description
           end) do
          :conflict
        else
          :ok
        end

      Enum.map(events, fn event ->
        %Row{
          status: status,
          event: event,
          date: date,
          start_time: start_time,
          end_time: end_time,
          conflicting_events: events
        }
      end)
    end)
    |> group_sorted_by(fn row -> row.date end)
  end

  @doc """
  Takes in a sorted list of elements and a key function, returns a list of tuples in the form of:
  [{key, [element, element...]}, ...]

  NOTE: A precondition of this is that the items must _already_ be sorted according to keyfn.
  """
  # TODO: Stick this into a util module?
  def group_sorted_by(sorted, keyfn) do
    sorted
    |> Enum.reverse()
    |> Enum.reduce([], fn item, acc ->
      key = keyfn.(item)

      case acc do
        [] -> [{key, [item]}]
        [{^key, items} | rest] -> [{key, [item | items]} | rest]
        _ -> [{key, [item]} | acc]
      end
    end)
  end
end
