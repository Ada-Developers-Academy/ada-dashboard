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
  def events_for_class(%Class{} = class, start_date) do
    # TODO: Assert all calendars have the same time zone.
    Repo.all(
      from e in Event,
        join: c in Calendar,
        on: e.calendar_id == c.id,
        join: s in Source,
        on: s.calendar_id == c.id,
        where: s.class_id == ^class.id,
        order_by: e.start_time,
        preload: :calendar
    )
    |> group_sorted_by(fn e -> e.start_time end)
    |> Enum.map(fn {start_time_utc, [first | rest] = events} ->
      start_datetime = DateTime.shift_zone!(start_time_utc, first.calendar.timezone)
      end_datetime = DateTime.shift_zone!(first.end_time, first.calendar.timezone)
      # TODO: Move date formatting into the view layer?
      {:ok, date} = Timex.format(start_datetime, "{WDfull} {M}/{D}")
      {:ok, start_time} = Timex.format(start_datetime, "{h12}:{m}")
      {:ok, end_time} = Timex.format(end_datetime, "{h12}:{m}")

      {status, error_message, conflicting_events} =
        cond do
          # TODO: Flag if multiple mismatches exist.
          Enum.any?(rest, fn e -> e.end_time != first.end_time end) ->
            {:error, "End times don't match.", events}

          Enum.any?(rest, fn e -> e.title != first.title end) ->
            {:error, "Titles don't match.", events}

          Enum.any?(rest, fn e -> e.description != first.description end) ->
            {:error, "Descriptions don't match.", events}

          true ->
            {:ok, nil, []}
        end

      %Row{
        status: status,
        error_message: error_message,
        event: first,
        date: date,
        start_time: start_time,
        end_time: end_time,
        conflicting_events: conflicting_events
      }
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
