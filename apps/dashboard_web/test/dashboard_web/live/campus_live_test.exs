defmodule DashboardWeb.CampusLiveTest do
  use DashboardWeb.ConnCase

  import Phoenix.LiveViewTest
  import Dashboard.CampusesFixtures

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  defp create_campus(_) do
    campus = campus_fixture()
    %{campus: campus}
  end

  describe "Index" do
    setup [:create_campus]

    test "lists all campus", %{conn: conn, campus: campus} do
      {:ok, _index_live, html} = live(conn, Routes.campus_index_path(conn, :index))

      assert html =~ "Listing Campus"
      assert html =~ campus.name
    end

    test "saves new campus", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.campus_index_path(conn, :index))

      assert index_live |> element("a", "New Campus") |> render_click() =~
               "New Campus"

      assert_patch(index_live, Routes.campus_index_path(conn, :new))

      assert index_live
             |> form("#campus-form", campus: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#campus-form", campus: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.campus_index_path(conn, :index))

      assert html =~ "Campus created successfully"
      assert html =~ "some name"
    end

    test "updates campus in listing", %{conn: conn, campus: campus} do
      {:ok, index_live, _html} = live(conn, Routes.campus_index_path(conn, :index))

      assert index_live |> element("#campus-#{campus.id} a", "Edit") |> render_click() =~
               "Edit Campus"

      assert_patch(index_live, Routes.campus_index_path(conn, :edit, campus))

      assert index_live
             |> form("#campus-form", campus: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#campus-form", campus: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.campus_index_path(conn, :index))

      assert html =~ "Campus updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes campus in listing", %{conn: conn, campus: campus} do
      {:ok, index_live, _html} = live(conn, Routes.campus_index_path(conn, :index))

      assert index_live |> element("#campus-#{campus.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#campus-#{campus.id}")
    end
  end

  describe "Show" do
    setup [:create_campus]

    test "displays campus", %{conn: conn, campus: campus} do
      {:ok, _show_live, html} = live(conn, Routes.campus_show_path(conn, :show, campus))

      assert html =~ "Show Campus"
      assert html =~ campus.name
    end

    test "updates campus within modal", %{conn: conn, campus: campus} do
      {:ok, show_live, _html} = live(conn, Routes.campus_show_path(conn, :show, campus))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Campus"

      assert_patch(show_live, Routes.campus_show_path(conn, :edit, campus))

      assert show_live
             |> form("#campus-form", campus: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#campus-form", campus: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.campus_show_path(conn, :show, campus))

      assert html =~ "Campus updated successfully"
      assert html =~ "some updated name"
    end
  end
end
