defmodule Dashboard.CampusesTest do
  use Dashboard.DataCase

  alias Dashboard.Campuses

  describe "campus" do
    alias Dashboard.Campuses.Campus

    import Dashboard.CampusesFixtures

    @invalid_attrs %{name: nil}

    test "list_campus/0 returns all campus" do
      campus = campus_fixture()
      assert Campuses.list_campus() == [campus]
    end

    test "get_campus!/1 returns the campus with given id" do
      campus = campus_fixture()
      assert Campuses.get_campus!(campus.id) == campus
    end

    test "create_campus/1 with valid data creates a campus" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Campus{} = campus} = Campuses.create_campus(valid_attrs)
      assert campus.name == "some name"
    end

    test "create_campus/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Campuses.create_campus(@invalid_attrs)
    end

    test "update_campus/2 with valid data updates the campus" do
      campus = campus_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Campus{} = campus} = Campuses.update_campus(campus, update_attrs)
      assert campus.name == "some updated name"
    end

    test "update_campus/2 with invalid data returns error changeset" do
      campus = campus_fixture()
      assert {:error, %Ecto.Changeset{}} = Campuses.update_campus(campus, @invalid_attrs)
      assert campus == Campuses.get_campus!(campus.id)
    end

    test "delete_campus/1 deletes the campus" do
      campus = campus_fixture()
      assert {:ok, %Campus{}} = Campuses.delete_campus(campus)
      assert_raise Ecto.NoResultsError, fn -> Campuses.get_campus!(campus.id) end
    end

    test "change_campus/1 returns a campus changeset" do
      campus = campus_fixture()
      assert %Ecto.Changeset{} = Campuses.change_campus(campus)
    end
  end
end
