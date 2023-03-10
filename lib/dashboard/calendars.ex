defmodule Dashboard.Calendars do
  @moduledoc """
  The Calendars context.
  """

  import Ecto.Query, warn: false
  alias Dashboard.Repo

  alias Dashboard.Calendars.Calendar
  alias Dashboard.Calendars.Event
  alias Dashboard.Classes.Source

  @doc """
  Returns the list of calendars.

  ## Examples

  iex> list_calendars()
  [%Calendar{}, ...]

  """
  def list_calendars do
    Repo.all(Calendar)
  end

  @doc """
  Returns id, name, and "connected" for the list of calendars
  relating to the provided class.

  ## Examples

  iex> list_calendars_for_class(class)
  [%{id: ..., name: ..., connected: ...}, ...]

  """
  def list_calendars_for_class(class) do
    Repo.all(
      from c in Calendar,
        left_join: s in Source,
        on: c.id == s.calendar_id and s.class_id == ^class.id,
        select: [id: c.id, name: c.name, connected: not is_nil(s.calendar_id)],
        where: c.is_personal == false,
        distinct: true,
        order_by: c.name
    )
    |> Enum.map(&Enum.into(&1, %{}))
  end

  @doc """
  Gets a single calendar.

  Raises `Ecto.NoResultsError` if the Calendar does not exist.

  ## Examples

  iex> get_calendar!(123)
  %Calendar{}

  iex> get_calendar!(456)
  ** (Ecto.NoResultsError)

  """
  def get_calendar!(id), do: Repo.get!(Calendar, id)

  @doc """
  Creates a calendar.

  ## Examples

  iex> create_calendar(%{field: value})
  {:ok, %Calendar{}}

  iex> create_calendar(%{field: bad_value})
  {:error, %Ecto.Changeset{}}

  """
  def create_calendar(attrs \\ %{}) do
    %Calendar{}
    |> Calendar.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a calendar; updates if already exists.

  ## Examples

  iex> create_or_update_calendar(%{field: value})
  {:ok, %Calendar{}}

  iex> create_or_update_calendar(%{field: bad_value})
  {:error, %Ecto.Changeset{}}

  """
  def create_or_update_calendar(attrs \\ %{}) do
    %Calendar{}
    |> Calendar.changeset(attrs)
    |> Repo.insert(
      on_conflict: :replace_all,
      conflict_target: [:external_id, :external_provider]
    )
  end

  @doc """
  Returns the matching calendar; creates it if it doesn't exist.

  ## Examples

  iex> get_or_create_calendar(%{field: value})
  %Calendar{}

  iex> get_or_create_calendar(%{field: bad_value})
  raises Ecto.ChangesetError

  """
  def get_or_create_calendar(attrs \\ %{}) do
    calendar =
      Repo.get_by(
        Calendar,
        external_provider: attrs.external_provider,
        external_id: attrs.external_id
      )

    if is_nil(calendar) do
      %Calendar{}
      |> Calendar.changeset(attrs)
      |> Repo.insert(on_conflict: :nothing)
    else
      {:ok, calendar}
    end
  end

  @doc """
  Updates a calendar.

  ## Examples

  iex> update_calendar(calendar, %{field: new_value})
  {:ok, %Calendar{}}

  iex> update_calendar(calendar, %{field: bad_value})
  {:error, %Ecto.Changeset{}}

  """
  def update_calendar(%Calendar{} = calendar, attrs) do
    calendar
    |> Calendar.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a calendar.

  ## Examples

  iex> delete_calendar(calendar)
  {:ok, %Calendar{}}

  iex> delete_calendar(calendar)
  {:error, %Ecto.Changeset{}}

  """
  def delete_calendar(%Calendar{} = calendar) do
    Repo.delete(calendar)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking calendar changes.

  ## Examples

  iex> change_calendar(calendar)
  %Ecto.Changeset{data: %Calendar{}}

  """
  def change_calendar(%Calendar{} = calendar, attrs \\ %{}) do
    Calendar.changeset(calendar, attrs)
  end

  alias Dashboard.Calendars.Event

  @doc """
  Returns the list of events.

  ## Examples

  iex> list_events()
  [%Event{}, ...]

  """
  def list_events do
    Repo.all(from e in Event, where: is_nil(e.deleted_at))
  end

  @doc """
  Returns the list of events for the given calendar.

  ## Examples

  iex> list_events(calendar_id)
  [%Event{}, ...]

  """
  def list_calendar_events(calendar_id) do
    Repo.all(from e in Event, where: e.calendar_id == ^calendar_id and is_nil(e.deleted_at))
  end

  @doc """
  Gets a single event.

  Raises `Ecto.NoResultsError` if the Event does not exist.

  ## Examples

  iex> get_event!(123)
  %Event{}

  iex> get_event!(456)
  ** (Ecto.NoResultsError)

  """
  def get_event!(id), do: Repo.get!(Event, id)

  @doc """
  Creates a event.

  ## Examples

  iex> create_event(%{field: value})
  {:ok, %Event{}}

  iex> create_event(%{field: bad_value})
  {:error, %Ecto.Changeset{}}

  """
  def create_event(attrs \\ %{}) do
    %Event{}
    |> Event.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns the matching calendar; creates it if it doesn't exist.

  ## Examples

  iex> get_or_create_event(%{field: value})
  %Event{}

  iex> get_or_create_event!(%{field: bad_value})
  raises Ecto.ChangesetError

  """
  def get_or_create_event!(attrs \\ %{}) do
    event =
      Repo.get_by(
        Event,
        external_provider: attrs.external_provider,
        external_id: attrs.external_id
      )

    if is_nil(event) do
      %Event{}
      |> Event.changeset(attrs)
      |> Repo.insert!(on_conflict: :nothing)
    else
      event
    end
  end

  @doc """
  Updates a event.

  ## Examples

  iex> update_event(event, %{field: new_value})
  {:ok, %Event{}}

  iex> update_event(event, %{field: bad_value})
  {:error, %Ecto.Changeset{}}

  """
  def update_event(%Event{} = event, attrs) do
    event
    |> Event.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a event.

  ## Examples

  iex> delete_event(event)
  {:ok, %Event{}}

  iex> delete_event(event)
  {:error, %Ecto.Changeset{}}

  """
  def delete_event(%Event{} = event) do
    Repo.delete(event)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking event changes.

  ## Examples

  iex> change_event(event)
  %Ecto.Changeset{data: %Event{}}

  """
  def change_event(%Event{} = event, attrs \\ %{}) do
    Event.changeset(event, attrs)
  end

  @doc """
  Marks events for a given calendar deleted if they no longer exist.
  """
  def mark_events_deleted(calendar, events) do
    existing_events =
      Enum.into(events, %{}, fn event ->
        {event.id, event}
      end)

    Enum.each(calendar.events, fn event ->
      if Map.get(existing_events, event.id) do
        update_event(event, %{deleted_at: nil})
      else
        update_event(event, %{deleted_at: DateTime.utc_now()})
      end
    end)
  end
end
