defmodule Dashboard.CalendarsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Dashboard.Calendars` context.
  """

  @doc """
  Generate a calendar.
  """
  def calendar_fixture(attrs \\ %{}) do
    {:ok, calendar} =
      attrs
      |> Enum.into(%{
        external_id: "some external_id",
        external_provider: "some external_provider",
        name: "some name"
      })
      |> Dashboard.Calendars.create_calendar()

    calendar
  end

  @doc """
  Generate a event.
  """
  def event_fixture(attrs \\ %{}) do
    {:ok, event} =
      attrs
      |> Enum.into(%{
        description: "some description",
        external_id: "some external_id",
        external_provider: "some external_provider",
        name: "some name"
      })
      |> Dashboard.Calendars.create_event()

    event
  end
end
