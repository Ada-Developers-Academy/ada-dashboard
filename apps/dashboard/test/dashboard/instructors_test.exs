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
end
