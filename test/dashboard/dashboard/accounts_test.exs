defmodule Dashboard.AccountsTest do
  use Dashboard.DataCase

  alias Dashboard.Accounts

  describe "instructors" do
    alias Dashboard.Accounts.Instructor

    import Dashboard.AccountsFixtures

    @invalid_attrs %{
      background_color: nil,
      email: nil,
      external_id: nil,
      external_provider: nil,
      name: nil
    }

    test "list_instructors/0 returns all instructors" do
      instructor = instructor_fixture()
      assert Accounts.list_instructors() == [instructor]
    end

    test "get_instructor!/1 returns the instructor with given id" do
      instructor = instructor_fixture()
      assert Accounts.get_instructor!(instructor.id) == instructor
    end

    test "create_instructor/1 with valid data creates a instructor" do
      valid_attrs = %{
        background_color: "some background_color",
        email: "some email",
        external_id: "some external_id",
        external_provider: "some external_provider",
        name: "some name"
      }

      assert {:ok, %Instructor{} = instructor} = Accounts.create_instructor(valid_attrs)
      assert instructor.background_color == "some background_color"
      assert instructor.email == "some email"
      assert instructor.external_id == "some external_id"
      assert instructor.external_provider == "some external_provider"
      assert instructor.name == "some name"
    end

    test "create_instructor/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_instructor(@invalid_attrs)
    end

    test "update_instructor/2 with valid data updates the instructor" do
      instructor = instructor_fixture()

      update_attrs = %{
        background_color: "some updated background_color",
        email: "some updated email",
        external_id: "some updated external_id",
        external_provider: "some updated external_provider",
        name: "some updated name"
      }

      assert {:ok, %Instructor{} = instructor} =
               Accounts.update_instructor(instructor, update_attrs)

      assert instructor.background_color == "some updated background_color"
      assert instructor.email == "some updated email"
      assert instructor.external_id == "some updated external_id"
      assert instructor.external_provider == "some updated external_provider"
      assert instructor.name == "some updated name"
    end

    test "update_instructor/2 with invalid data returns error changeset" do
      instructor = instructor_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_instructor(instructor, @invalid_attrs)
      assert instructor == Accounts.get_instructor!(instructor.id)
    end

    test "delete_instructor/1 deletes the instructor" do
      instructor = instructor_fixture()
      assert {:ok, %Instructor{}} = Accounts.delete_instructor(instructor)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_instructor!(instructor.id) end
    end

    test "change_instructor/1 returns a instructor changeset" do
      instructor = instructor_fixture()
      assert %Ecto.Changeset{} = Accounts.change_instructor(instructor)
    end
  end
end
