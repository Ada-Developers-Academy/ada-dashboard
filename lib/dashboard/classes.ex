defmodule Dashboard.Classes do
  @moduledoc """
  The Classes context.
  """

  import Ecto.Query, warn: false

  alias Dashboard.Accounts.Claim
  alias Dashboard.Accounts.Instructor
  alias Dashboard.Calendars.Calendar
  alias Dashboard.Calendars.Event
  alias Dashboard.Classes.Class
  alias Dashboard.Classes.Source
  alias Dashboard.Repo

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
  Gets a single class with Cohort and Campus preloaded.

  Raises `Ecto.NoResultsError` if the Class does not exist.

  ## Examples

  iex> get_class_with_cohort_and_campus!(123)
  %Class{cohort: %Cohort{campus: %Campus{}}}

  iex> get_class_with_cohort_and_campus!(456)
  ** (Ecto.NoResultsError)

  """
  def get_class_with_cohort_and_campus!(id) do
    Repo.one!(
      from c in Class,
        join: cohort in assoc(c, :cohort),
        join: campus in assoc(cohort, :campus),
        where: c.id == ^id,
        limit: 1,
        preload: [cohort: {cohort, [campus: campus]}]
    )
  end

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
  Returns all events for a given instructor.
  """
  def events_for_instructor(_instructor, nil), do: nil

  def events_for_instructor(%Instructor{} = instructor, start_date) do
    end_time = Timex.end_of_week(start_date)

    claims =
      Repo.all(
        from c in Claim,
          join: i in Instructor,
          on: c.instructor_id == i.id and i.id == ^instructor.id,
          join: e in Event,
          on: c.event_id == e.id,
          left_join: event in assoc(c, :event),
          left_join: cohort in assoc(c, :cohort),
          left_join: class in assoc(c, :class),
          where: ^start_date <= e.start_time and e.end_time <= ^end_time and is_nil(e.deleted_at),
          order_by: e.start_time,
          distinct: true,
          preload: [class: class, cohort: cohort, event: event],
          select: [c, e.start_time]
      )

    claims
    |> Enum.map(fn [claim, _] -> claim end)
    |> Enum.reverse()
    |> Enum.reduce({[], %{}}, fn claim, {events, claim_lookup} ->
      {[claim.event | events], Map.put(claim_lookup, claim.event.id, claim)}
    end)
  end

  @doc """
  Returns all events for given classes.
  """
  def events_for_classes(_classes, nil), do: nil

  def events_for_classes(classes, start_date) do
    end_time = Timex.end_of_week(start_date)
    class_ids = Enum.map(classes, fn c -> c.id end)

    Repo.all(
      from e in Event,
        join: c in Calendar,
        on: e.calendar_id == c.id,
        join: s in Source,
        on: s.calendar_id == c.id,
        where:
          s.class_id in ^class_ids and ^start_date <= e.start_time and e.end_time <= ^end_time and
            is_nil(e.deleted_at),
        order_by: e.start_time,
        distinct: true,
        preload: [calendar: c]
    )
  end
end
