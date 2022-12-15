defmodule Dashboard.Instructors do
  @moduledoc """
  The Instructors context.
  """

  import Ecto.Query, warn: false
  alias Dashboard.Repo

  alias Dashboard.Instructors.Affinity

  @doc """
  Returns the list of affinities.

  ## Examples

      iex> list_affinities()
      [%Affinity{}, ...]

  """
  def list_affinities do
    Repo.all(Affinity)
  end

  @doc """
  Gets a single affinity.

  Raises `Ecto.NoResultsError` if the Affinity does not exist.

  ## Examples

      iex> get_affinity!(123)
      %Affinity{}

      iex> get_affinity!(456)
      ** (Ecto.NoResultsError)

  """
  def get_affinity!(id), do: Repo.get!(Affinity, id)

  @doc """
  Creates a affinity.

  ## Examples

      iex> create_affinity(%{field: value})
      {:ok, %Affinity{}}

      iex> create_affinity(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_affinity(attrs \\ %{}) do
    %Affinity{}
    |> Affinity.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a affinity.

  ## Examples

      iex> update_affinity(affinity, %{field: new_value})
      {:ok, %Affinity{}}

      iex> update_affinity(affinity, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_affinity(%Affinity{} = affinity, attrs) do
    affinity
    |> Affinity.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a affinity.

  ## Examples

      iex> delete_affinity(affinity)
      {:ok, %Affinity{}}

      iex> delete_affinity(affinity)
      {:error, %Ecto.Changeset{}}

  """
  def delete_affinity(%Affinity{} = affinity) do
    Repo.delete(affinity)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking affinity changes.

  ## Examples

      iex> change_affinity(affinity)
      %Ecto.Changeset{data: %Affinity{}}

  """
  def change_affinity(%Affinity{} = affinity, attrs \\ %{}) do
    Affinity.changeset(affinity, attrs)
  end
end
