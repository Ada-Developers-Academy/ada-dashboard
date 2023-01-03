defmodule Dashboard.CalendarsTest do
  use Dashboard.DataCase

  alias Dashboard.Calendars

  describe "calendars" do
    alias Dashboard.Calendars.Calendar

    import Dashboard.CalendarsFixtures

    @invalid_attrs %{external_id: nil, external_provider: nil, name: nil}

    test "list_calendars/0 returns all calendars" do
      calendar = calendar_fixture()
      assert Calendars.list_calendars() == [calendar]
    end

    test "get_calendar!/1 returns the calendar with given id" do
      calendar = calendar_fixture()
      assert Calendars.get_calendar!(calendar.id) == calendar
    end

    test "create_calendar/1 with valid data creates a calendar" do
      valid_attrs = %{
        external_id: "some external_id",
        external_provider: "some external_provider",
        name: "some name"
      }

      assert {:ok, %Calendar{} = calendar} = Calendars.create_calendar(valid_attrs)
      assert calendar.external_id == "some external_id"
      assert calendar.external_provider == "some external_provider"
      assert calendar.name == "some name"
    end

    test "create_calendar/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Calendars.create_calendar(@invalid_attrs)
    end

    test "update_calendar/2 with valid data updates the calendar" do
      calendar = calendar_fixture()

      update_attrs = %{
        external_id: "some updated external_id",
        external_provider: "some updated external_provider",
        name: "some updated name"
      }

      assert {:ok, %Calendar{} = calendar} = Calendars.update_calendar(calendar, update_attrs)
      assert calendar.external_id == "some updated external_id"
      assert calendar.external_provider == "some updated external_provider"
      assert calendar.name == "some updated name"
    end

    test "update_calendar/2 with invalid data returns error changeset" do
      calendar = calendar_fixture()
      assert {:error, %Ecto.Changeset{}} = Calendars.update_calendar(calendar, @invalid_attrs)
      assert calendar == Calendars.get_calendar!(calendar.id)
    end

    test "delete_calendar/1 deletes the calendar" do
      calendar = calendar_fixture()
      assert {:ok, %Calendar{}} = Calendars.delete_calendar(calendar)
      assert_raise Ecto.NoResultsError, fn -> Calendars.get_calendar!(calendar.id) end
    end

    test "change_calendar/1 returns a calendar changeset" do
      calendar = calendar_fixture()
      assert %Ecto.Changeset{} = Calendars.change_calendar(calendar)
    end
  end

  describe "events" do
    alias Dashboard.Calendars.Event

    import Dashboard.CalendarsFixtures

    @invalid_attrs %{description: nil, external_id: nil, external_provider: nil, name: nil}

    test "list_events/0 returns all events" do
      event = event_fixture()
      assert Calendars.list_events() == [event]
    end

    test "get_event!/1 returns the event with given id" do
      event = event_fixture()
      assert Calendars.get_event!(event.id) == event
    end

    test "create_event/1 with valid data creates a event" do
      valid_attrs = %{
        description: "some description",
        external_id: "some external_id",
        external_provider: "some external_provider",
        name: "some name"
      }

      assert {:ok, %Event{} = event} = Calendars.create_event(valid_attrs)
      assert event.description == "some description"
      assert event.external_id == "some external_id"
      assert event.external_provider == "some external_provider"
      assert event.name == "some name"
    end

    test "create_event/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Calendars.create_event(@invalid_attrs)
    end

    test "update_event/2 with valid data updates the event" do
      event = event_fixture()

      update_attrs = %{
        description: "some updated description",
        external_id: "some updated external_id",
        external_provider: "some updated external_provider",
        name: "some updated name"
      }

      assert {:ok, %Event{} = event} = Calendars.update_event(event, update_attrs)
      assert event.description == "some updated description"
      assert event.external_id == "some updated external_id"
      assert event.external_provider == "some updated external_provider"
      assert event.name == "some updated name"
    end

    test "update_event/2 with invalid data returns error changeset" do
      event = event_fixture()
      assert {:error, %Ecto.Changeset{}} = Calendars.update_event(event, @invalid_attrs)
      assert event == Calendars.get_event!(event.id)
    end

    test "delete_event/1 deletes the event" do
      event = event_fixture()
      assert {:ok, %Event{}} = Calendars.delete_event(event)
      assert_raise Ecto.NoResultsError, fn -> Calendars.get_event!(event.id) end
    end

    test "change_event/1 returns a event changeset" do
      event = event_fixture()
      assert %Ecto.Changeset{} = Calendars.change_event(event)
    end
  end
end
