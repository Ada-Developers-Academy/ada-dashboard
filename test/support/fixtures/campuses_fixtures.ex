defmodule Dashboard.CampusesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Dashboard.Campuses` context.
  """

  @doc """
  Generate a campus.
  """
  def campus_fixture(attrs \\ %{}) do
    {:ok, campus} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Dashboard.Campuses.create_campus()

    campus
  end
end
