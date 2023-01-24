defmodule Dashboard.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false

  alias Dashboard.Accounts.Claim
  alias Dashboard.Accounts.Instructor
  alias Dashboard.Accounts.Residence
  alias Dashboard.Calendars.Event
  alias Dashboard.Campuses.Campus
  alias Dashboard.Repo
  alias DashboardWeb.CalendarLive.Location
  alias Ecto.Multi

  @doc """
  Returns the list of instructors.

  ## Examples

      iex> list_instructors()
      [%Instructor{}, ...]

  """
  def list_instructors do
    Repo.all(Instructor)
  end

  @doc """
  Gets a single instructor.

  Raises `Ecto.NoResultsError` if the Instructor does not exist.

  ## Examples

      iex> get_instructor!(123)
      %Instructor{}

      iex> get_instructor!(456)
      ** (Ecto.NoResultsError)

  """
  def get_instructor!(id), do: Repo.get!(Instructor, id)

  @doc """
  Gets a single instructorwith campuses and events preloaded.

  Raises `Ecto.NoResultsError` if the Instructor does not exist.

  ## Examples

      iex> get_with_campuses_and_events!(123)
      %Instructor{campuses: [%Campus{}, ...], events: [%Event{}, ...]}

      iex> get_with_campuses_and_events!(456)
      ** (Ecto.NoResultsError)
  """
  def get_with_campuses_and_events!(instructor_id) do
    Repo.one(
      from i in Instructor,
        join: c in assoc(i, :campuses),
        join: e in assoc(i, :events),
        preload: [campuses: c, events: e],
        where: i.id == ^instructor_id,
        limit: 1
    )
  end

  def get_instructor_by_external_id(external_provider, external_id) do
    Repo.get_by(
      Instructor,
      external_provider: external_provider,
      external_id: external_id
    )
  end

  @doc """
  Creates a instructor.

  ## Examples

      iex> create_instructor(%{field: value})
      {:ok, %Instructor{}}

      iex> create_instructor(%{field: bad_value})
      {:error, %Ecto.Changeset{}}
  """
  def create_instructor(attrs \\ %{}) do
    %Instructor{}
    |> Instructor.changeset(attrs)
    |> Repo.insert()
  end

  def create_guest_instructor(
        %{name: name},
        %Campus{} = campus,
        claim_type,
        %Location{} = location,
        %Event{} = event
      ) do
    Multi.new()
    |> Multi.insert(
      :instructor,
      Instructor.changeset(%Instructor{}, %{name: name, is_guest: true})
    )
    |> Multi.insert(:residence, fn %{instructor: instructor} ->
      %Residence{instructor_id: instructor.id, campus_id: campus.id}
    end)
    |> Multi.insert(:claim, fn %{instructor: instructor} ->
      case location do
        %Location{id: class_id, model: :class} ->
          %Claim{
            instructor_id: instructor.id,
            event_id: event.id,
            type: claim_type,
            class_id: class_id
          }

        %Location{id: cohort_id, model: :cohort} ->
          %Claim{
            instructor_id: instructor.id,
            event_id: event.id,
            type: claim_type,
            cohort_id: cohort_id
          }
      end
    end)
    |> Repo.transaction()
  end

  @doc """
  Creates a instructor; updates if already exists.

  ## Examples

      iex> create_or_update_instructor(%{field: value})
      {:ok, %Instructor{}}

      iex> create_or_update_instructor(%{field: bad_value})
      {:error, %Ecto.Changeset{}}
  """
  def create_or_update_instructor(%{external_provider: provider, external_id: id} = attrs) do
    Repo.transaction(fn ->
      instructor = get_instructor_by_external_id(provider, id)

      if instructor do
        instructor
      else
        {:ok, created} =
          %Instructor{}
          |> Instructor.changeset(attrs)
          |> Repo.insert(returning: true)

        # TODO: Handle errors
        created
      end
    end)
  end

  @doc """
  Updates a instructor.

  ## Examples

      iex> update_instructor(instructor, %{field: new_value})
      {:ok, %Instructor{}}

      iex> update_instructor(instructor, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_instructor(%Instructor{} = instructor, attrs) do
    instructor
    |> Instructor.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a instructor.

  ## Examples

      iex> delete_instructor(instructor)
      {:ok, %Instructor{}}

      iex> delete_instructor(instructor)
      {:error, %Ecto.Changeset{}}

  """
  def delete_instructor(%Instructor{} = instructor) do
    Repo.delete(instructor)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking instructor changes.

  ## Examples

      iex> change_instructor(instructor)
      %Ecto.Changeset{data: %Instructor{}}

  """
  def change_instructor(%Instructor{} = instructor, attrs \\ %{}) do
    Instructor.changeset(instructor, attrs)
  end

  @doc """
  Returns a list of tuples of {name, color} where name is from the email address.
  """
  def all_names_and_colors do
    Repo.all(Instructor)
    |> Enum.flat_map(fn instructor ->
      if instructor.email do
        [name | _] = String.split(instructor.email, "@")

        if instructor.background_color do
          [{name, instructor.background_color}]
        else
          []
        end
      else
        []
      end
    end)
  end

  @doc """
  Returns the list of claims.

  ## Examples

      iex> list_claims()
      [%Claim{}, ...]

  """
  def list_claims do
    Repo.all(Claim)
  end

  @doc """
  Gets a single claim.

  Raises `Ecto.NoResultsError` if the Claim does not exist.

  ## Examples

      iex> get_claim!(123)
      %Claim{}

      iex> get_claim!(456)
      ** (Ecto.NoResultsError)

  """
  def get_claim!(id), do: Repo.get!(Claim, id)

  @doc """
  Creates a claim.

  ## Examples

      iex> create_claim(%{field: value})
      {:ok, %Claim{}}

      iex> create_claim(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_claim(attrs \\ %{}) do
    %Claim{}
    |> Claim.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a claim.

  ## Examples

      iex> update_claim(claim, %{field: new_value})
      {:ok, %Claim{}}

      iex> update_claim(claim, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_claim(%Claim{} = claim, attrs) do
    claim
    |> Claim.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a claim.

  ## Examples

      iex> delete_claim(claim)
      {:ok, %Claim{}}

      iex> delete_claim(claim)
      {:error, %Ecto.Changeset{}}

  """
  def delete_claim(%Claim{} = claim) do
    Repo.delete(claim)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking claim changes.

  ## Examples

      iex> change_claim(claim)
      %Ecto.Changeset{data: %Claim{}}

  """
  def change_claim(%Claim{} = claim, attrs \\ %{}) do
    Claim.changeset(claim, attrs)
  end

  @doc """
  Returns true if the instructor and campus are connected.

  Returns false if they are not.
  """
  def has_residence(instructor, campus) do
    !is_nil(Repo.get_by(Residence, instructor_id: instructor.id, campus_id: campus.id))
  end

  @doc """
  Ensure the claim exists if connected is true, and that it doesn't otherwise.
  """
  def create_or_delete_claim(instructor, location, event, type) do
    Repo.transaction(fn ->
      claim =
        case location do
          %Location{id: class_id, model: :class} ->
            Repo.get_by(Claim,
              instructor_id: instructor.id,
              class_id: class_id,
              event_id: event.id
            )

          %Location{id: cohort_id, model: :cohort} ->
            Repo.get_by(Claim,
              instructor_id: instructor.id,
              cohort_id: cohort_id,
              event_id: event.id
            )
        end

      case {claim, type} do
        {nil, nil} ->
          nil

        {claim, nil} ->
          Repo.delete!(claim)

        {_, type} ->
          claim =
            case location do
              %Location{id: class_id, model: :class} ->
                %Claim{
                  instructor_id: instructor.id,
                  class_id: class_id,
                  event_id: event.id,
                  type: type
                }

              %Location{id: cohort_id, model: :cohort} ->
                %Claim{
                  instructor_id: instructor.id,
                  cohort_id: cohort_id,
                  event_id: event.id,
                  type: type
                }
            end

          Repo.insert!(claim,
            on_conflict: :replace_all,
            conflict_target: [:instructor_id, :event_id]
          )
      end
    end)
  end

  @doc """
  Ensure the connection exists if connected is true, and that it doesn't otherwise.
  """
  def create_or_delete_residence(instructor, campus, connected) do
    Repo.transaction(fn ->
      affinity = Repo.get_by(Residence, instructor_id: instructor.id, campus_id: campus.id)

      case {affinity, connected} do
        {nil, true} ->
          residence = %Residence{instructor_id: instructor.id, campus_id: campus.id}
          Repo.insert!(residence)

        {nil, false} ->
          nil

        {_source, false} ->
          Repo.delete!(affinity)
      end
    end)
  end
end
