defmodule Dashboard.Cohorts do
  @moduledoc """
  The Cohorts context.
  """

  import Ecto.Query, warn: false
  alias Dashboard.Repo

  alias Dashboard.Cohorts.Cohort

  @doc """
  Returns the list of cohorts.

  ## Examples

      iex> list_cohorts()
      [%Cohort{}, ...]

  """
  def list_cohorts do
    Repo.all(Cohort)
  end

  @doc """
  Gets a single cohort.

  Raises `Ecto.NoResultsError` if the Cohort does not exist.

  ## Examples

      iex> get_cohort!(123)
      %Cohort{}

      iex> get_cohort!(456)
      ** (Ecto.NoResultsError)

  """
  def get_cohort!(id) do
    Repo.get(Cohort, id)
  end

  @doc """
  Gets a single cohort.

  Raises `Ecto.NoResultsError` if the Cohort does not exist.

  ## Examples

      iex> get_with_classes_cohorts_and_campuses!(123)
      %Cohort{campus: %Campus{}, classes: [%Class{}, ...]}

      iex> get_with_classes_cohorts_and_campuses!(456)
      ** (Ecto.NoResultsError)

  """
  def get_with_classes_cohorts_and_campuses!(id) do
    Repo.one(
      from c in Cohort,
        join: campus in assoc(c, :campus),
        left_join: classes in assoc(c, :classes),
        join: class_cohort in assoc(classes, :cohort),
        join: class_cohort_campus in assoc(class_cohort, :campus),
        where: c.id == ^id,
        distinct: c,
        preload: [
          campus: campus,
          classes:
            {classes,
             [
               cohort: {class_cohort, [campus: class_cohort_campus]}
             ]}
        ]
    )
  end

  @doc """
  Creates a cohort.

  ## Examples

      iex> create_cohort(%{field: value})
      {:ok, %Cohort{}}

      iex> create_cohort(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_cohort(attrs \\ %{}) do
    %Cohort{}
    |> Cohort.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a cohort.

  ## Examples

      iex> update_cohort(cohort, %{field: new_value})
      {:ok, %Cohort{}}

      iex> update_cohort(cohort, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_cohort(%Cohort{} = cohort, attrs) do
    cohort
    |> Cohort.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a cohort.

  ## Examples

      iex> delete_cohort(cohort)
      {:ok, %Cohort{}}

      iex> delete_cohort(cohort)
      {:error, %Ecto.Changeset{}}

  """
  def delete_cohort(%Cohort{} = cohort) do
    Repo.delete(cohort)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking cohort changes.

  ## Examples

      iex> change_cohort(cohort)
      %Ecto.Changeset{data: %Cohort{}}

  """
  def change_cohort(%Cohort{} = cohort, attrs \\ %{}) do
    Cohort.changeset(cohort, attrs)
  end
end
