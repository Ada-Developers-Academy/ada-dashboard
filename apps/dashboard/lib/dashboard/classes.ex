defmodule Dashboard.Classes do
  @moduledoc """
  The Classes context.
  """

  import Ecto.Query, warn: false
  alias Dashboard.Repo

  alias Dashboard.Classes.{Class, Source}

  @doc """
  Returns the list of class.

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
  Returns true if the class and calendar are connected.

  Returns false if they are not.
  """
  def has_source(class, calendar) do
    !is_nil(Repo.get_by(Source, class_id: class.id, calendar_id: calendar.id))
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
end
