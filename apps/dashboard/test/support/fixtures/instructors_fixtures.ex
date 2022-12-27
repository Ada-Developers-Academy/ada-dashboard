defmodule Dashboard.InstructorsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Dashboard.Instructors` context.
  """

  @doc """
  Generate a claim.
  """
  def claim_fixture(attrs \\ %{}) do
    {:ok, claim} =
      attrs
      |> Enum.into(%{})
      |> Dashboard.Instructors.create_claim()

    claim
  end

  @doc """
  Generate a affinity.
  """
  def affinity_fixture(attrs \\ %{}) do
    {:ok, affinity} =
      attrs
      |> Enum.into(%{})
      |> Dashboard.Instructors.create_affinity()

    affinity
  end
end
