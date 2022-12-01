defmodule Dashboard.CohortsTest do
  use Dashboard.DataCase

  alias Dashboard.Cohorts

  describe "cohort" do
    alias Dashboard.Cohorts.Cohort

    import Dashboard.CohortsFixtures

    @invalid_attrs %{name: nil}

    test "list_cohort/0 returns all cohort" do
      cohort = cohort_fixture()
      assert Cohorts.list_cohort() == [cohort]
    end

    test "get_cohort!/1 returns the cohort with given id" do
      cohort = cohort_fixture()
      assert Cohorts.get_cohort!(cohort.id) == cohort
    end

    test "create_cohort/1 with valid data creates a cohort" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Cohort{} = cohort} = Cohorts.create_cohort(valid_attrs)
      assert cohort.name == "some name"
    end

    test "create_cohort/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Cohorts.create_cohort(@invalid_attrs)
    end

    test "update_cohort/2 with valid data updates the cohort" do
      cohort = cohort_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Cohort{} = cohort} = Cohorts.update_cohort(cohort, update_attrs)
      assert cohort.name == "some updated name"
    end

    test "update_cohort/2 with invalid data returns error changeset" do
      cohort = cohort_fixture()
      assert {:error, %Ecto.Changeset{}} = Cohorts.update_cohort(cohort, @invalid_attrs)
      assert cohort == Cohorts.get_cohort!(cohort.id)
    end

    test "delete_cohort/1 deletes the cohort" do
      cohort = cohort_fixture()
      assert {:ok, %Cohort{}} = Cohorts.delete_cohort(cohort)
      assert_raise Ecto.NoResultsError, fn -> Cohorts.get_cohort!(cohort.id) end
    end

    test "change_cohort/1 returns a cohort changeset" do
      cohort = cohort_fixture()
      assert %Ecto.Changeset{} = Cohorts.change_cohort(cohort)
    end
  end
end
