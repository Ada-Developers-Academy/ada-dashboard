defmodule Dashboard.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Dashboard.Accounts` context.
  """

  @doc """
  Generate a instructor.
  """
  def instructor_fixture(attrs \\ %{}) do
    {:ok, instructor} =
      attrs
      |> Enum.into(%{
        background_color: "some background_color",
        email: "some email",
        external_id: "some external_id",
        external_provider: "some external_provider",
        name: "some name"
      })
      |> Dashboard.Accounts.create_instructor()

    instructor
  end
end
