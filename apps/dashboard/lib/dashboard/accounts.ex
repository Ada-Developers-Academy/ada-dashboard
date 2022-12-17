defmodule Dashboard.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Dashboard.Repo

  alias Dashboard.Accounts.{Affinity, Claim, Instructor}

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

      if is_nil(instructor) do
        %Instructor{}
        |> Instructor.changeset(attrs)
        |> Repo.insert()
      else
        instructor
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
      [name | _] = String.split(instructor.email, "@")

      if instructor.background_color do
        [{name, instructor.background_color}]
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
  Returns true if the class and calendar are connected.

  Returns false if they are not.
  """
  def has_affinity(instructor, class) do
    !is_nil(Repo.get_by(Affinity, instructor_id: instructor.id, class_id: class.id))
  end

  @doc """
  Ensure the connection exists if connected is true, and that it doesn't otherwise.
  """
  def create_or_delete_affinity(instructor, class, connected) do
    Repo.transaction(fn ->
      affinity = Repo.get_by(Affinity, instructor_id: instructor.id, class_id: class.id)

      case {affinity, connected} do
        {nil, true} ->
          affinity = %Affinity{instructor_id: instructor.id, class_id: class.id}
          Repo.insert!(affinity)

        {nil, false} ->
          nil

        {source, false} ->
          Repo.delete!(affinity)
      end
    end)
  end
end
