defmodule Dashboard.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Dashboard.Repo

  alias Dashboard.Accounts.Instructor

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

      iex> create_instructor!(%{field: value})
      %Instructor{}

      iex> create_instructor!(%{field: bad_value})
      ** (Ecto.ChangeError)
  """
  def create_instructor!(attrs \\ %{}) do
    %Instructor{}
    |> Instructor.changeset(attrs)
    |> Repo.insert!()
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
end
