defmodule DashboardWeb.CohortLiveTest do
  use DashboardWeb.ConnCase

  import Phoenix.LiveViewTest
  import Dashboard.CohortsFixtures

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  defp create_cohort(_) do
    cohort = cohort_fixture()
    %{cohort: cohort}
  end

  describe "Index" do
    setup [:create_cohort]

    test "lists all cohort", %{conn: conn, cohort: cohort} do
      {:ok, _index_live, html} = live(conn, Routes.cohort_index_path(conn, :index))

      assert html =~ "Listing Cohort"
      assert html =~ cohort.name
    end

    test "saves new cohort", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.cohort_index_path(conn, :index))

      assert index_live |> element("a", "New Cohort") |> render_click() =~
               "New Cohort"

      assert_patch(index_live, Routes.cohort_index_path(conn, :new))

      assert index_live
             |> form("#cohort-form", cohort: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#cohort-form", cohort: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.cohort_index_path(conn, :index))

      assert html =~ "Cohort created successfully"
      assert html =~ "some name"
    end

    test "updates cohort in listing", %{conn: conn, cohort: cohort} do
      {:ok, index_live, _html} = live(conn, Routes.cohort_index_path(conn, :index))

      assert index_live |> element("#cohort-#{cohort.id} a", "Edit") |> render_click() =~
               "Edit Cohort"

      assert_patch(index_live, Routes.cohort_index_path(conn, :edit, cohort))

      assert index_live
             |> form("#cohort-form", cohort: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#cohort-form", cohort: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.cohort_index_path(conn, :index))

      assert html =~ "Cohort updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes cohort in listing", %{conn: conn, cohort: cohort} do
      {:ok, index_live, _html} = live(conn, Routes.cohort_index_path(conn, :index))

      assert index_live |> element("#cohort-#{cohort.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#cohort-#{cohort.id}")
    end
  end

  describe "Show" do
    setup [:create_cohort]

    test "displays cohort", %{conn: conn, cohort: cohort} do
      {:ok, _show_live, html} = live(conn, Routes.cohort_show_path(conn, :show, cohort))

      assert html =~ "Show Cohort"
      assert html =~ cohort.name
    end

    test "updates cohort within modal", %{conn: conn, cohort: cohort} do
      {:ok, show_live, _html} = live(conn, Routes.cohort_show_path(conn, :show, cohort))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Cohort"

      assert_patch(show_live, Routes.cohort_show_path(conn, :edit, cohort))

      assert show_live
             |> form("#cohort-form", cohort: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#cohort-form", cohort: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.cohort_show_path(conn, :show, cohort))

      assert html =~ "Cohort updated successfully"
      assert html =~ "some updated name"
    end
  end
end
