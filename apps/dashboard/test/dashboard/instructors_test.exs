defmodule Dashboard.InstructorsTest do
  use Dashboard.DataCase

  alias Dashboard.Instructors

  describe "claims" do
    alias Dashboard.Instructors.Claim

    import Dashboard.InstructorsFixtures

    @invalid_attrs %{}

    test "list_claims/0 returns all claims" do
      claim = claim_fixture()
      assert Instructors.list_claims() == [claim]
    end

    test "get_claim!/1 returns the claim with given id" do
      claim = claim_fixture()
      assert Instructors.get_claim!(claim.id) == claim
    end

    test "create_claim/1 with valid data creates a claim" do
      valid_attrs = %{}

      assert {:ok, %Claim{} = claim} = Instructors.create_claim(valid_attrs)
    end

    test "create_claim/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Instructors.create_claim(@invalid_attrs)
    end

    test "update_claim/2 with valid data updates the claim" do
      claim = claim_fixture()
      update_attrs = %{}

      assert {:ok, %Claim{} = claim} = Instructors.update_claim(claim, update_attrs)
    end

    test "update_claim/2 with invalid data returns error changeset" do
      claim = claim_fixture()
      assert {:error, %Ecto.Changeset{}} = Instructors.update_claim(claim, @invalid_attrs)
      assert claim == Instructors.get_claim!(claim.id)
    end

    test "delete_claim/1 deletes the claim" do
      claim = claim_fixture()
      assert {:ok, %Claim{}} = Instructors.delete_claim(claim)
      assert_raise Ecto.NoResultsError, fn -> Instructors.get_claim!(claim.id) end
    end

    test "change_claim/1 returns a claim changeset" do
      claim = claim_fixture()
      assert %Ecto.Changeset{} = Instructors.change_claim(claim)
    end
  end

  describe "affinities" do
    alias Dashboard.Instructors.Affinity

    import Dashboard.InstructorsFixtures

    @invalid_attrs %{}

    test "list_affinities/0 returns all affinities" do
      affinity = affinity_fixture()
      assert Instructors.list_affinities() == [affinity]
    end

    test "get_affinity!/1 returns the affinity with given id" do
      affinity = affinity_fixture()
      assert Instructors.get_affinity!(affinity.id) == affinity
    end

    test "create_affinity/1 with valid data creates a affinity" do
      valid_attrs = %{}

      assert {:ok, %Affinity{} = affinity} = Instructors.create_affinity(valid_attrs)
    end

    test "create_affinity/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Instructors.create_affinity(@invalid_attrs)
    end

    test "update_affinity/2 with valid data updates the affinity" do
      affinity = affinity_fixture()
      update_attrs = %{}

      assert {:ok, %Affinity{} = affinity} = Instructors.update_affinity(affinity, update_attrs)
    end

    test "update_affinity/2 with invalid data returns error changeset" do
      affinity = affinity_fixture()
      assert {:error, %Ecto.Changeset{}} = Instructors.update_affinity(affinity, @invalid_attrs)
      assert affinity == Instructors.get_affinity!(affinity.id)
    end

    test "delete_affinity/1 deletes the affinity" do
      affinity = affinity_fixture()
      assert {:ok, %Affinity{}} = Instructors.delete_affinity(affinity)
      assert_raise Ecto.NoResultsError, fn -> Instructors.get_affinity!(affinity.id) end
    end

    test "change_affinity/1 returns a affinity changeset" do
      affinity = affinity_fixture()
      assert %Ecto.Changeset{} = Instructors.change_affinity(affinity)
    end
  end
end
