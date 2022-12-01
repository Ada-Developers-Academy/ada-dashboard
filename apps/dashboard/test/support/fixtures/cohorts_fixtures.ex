defmodule Dashboard.CohortsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Dashboard.Cohorts` context.
  """

  @doc """
  Generate a cohort.
  """
  def cohort_fixture(attrs \\ %{}) do
    {:ok, cohort} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Dashboard.Cohorts.create_cohort()

    cohort
  end
end
