defmodule Dashboard.Campuses do
  @moduledoc """
  The Campuses context.
  """

  import Ecto.Query, warn: false
  alias Dashboard.Repo

  alias Dashboard.Campuses.Campus
  alias Dashboard.Classes.Class

  @doc """
  Returns the list of campuses.

  ## Examples

      iex> list_campus()
      [%Campus{}, ...]

  """
  def list_campuses do
    Repo.all(Campus)
  end

  @doc """
  Returns the list of campuses with classes preloaded.

  ## Examples

      iex> list_campus()
      [%Campus{}, ...]

  """
  def list_campuses_with_classes do
    Repo.all(from c in Campus, preload: [:classes])
  end

  @doc """
  Gets a single campus.

  Raises `Ecto.NoResultsError` if the Campus does not exist.

  ## Examples

      iex> get_campus!(123)
      %Campus{}

      iex> get_campus!(456)
      ** (Ecto.NoResultsError)

  """
  def get_campus!(id), do: Repo.get!(Campus, id)

  @doc """
  Creates a campus.

  ## Examples

      iex> create_campus(%{field: value})
      {:ok, %Campus{}}

      iex> create_campus(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_campus(attrs \\ %{}) do
    %Campus{}
    |> Campus.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a campus.

  ## Examples

      iex> update_campus(campus, %{field: new_value})
      {:ok, %Campus{}}

      iex> update_campus(campus, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_campus(%Campus{} = campus, attrs) do
    campus
    |> Campus.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a campus.

  ## Examples

      iex> delete_campus(campus)
      {:ok, %Campus{}}

      iex> delete_campus(campus)
      {:error, %Ecto.Changeset{}}

  """
  def delete_campus(%Campus{} = campus) do
    campus
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.no_assoc_constraint(:classes)
    |> Repo.delete()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking campus changes.

  ## Examples

      iex> change_campus(campus)
      %Ecto.Changeset{data: %Campus{}}

  """
  def change_campus(%Campus{} = campus, attrs \\ %{}) do
    Campus.changeset(campus, attrs)
  end
end
