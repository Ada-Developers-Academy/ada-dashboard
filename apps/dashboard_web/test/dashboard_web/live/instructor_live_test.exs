defmodule DashboardWeb.InstructorLiveTest do
  use DashboardWeb.ConnCase

  import Phoenix.LiveViewTest
  import Dashboard.AccountsFixtures

  @create_attrs %{background_color: "some background_color", email: "some email", external_id: "some external_id", external_provider: "some external_provider", name: "some name"}
  @update_attrs %{background_color: "some updated background_color", email: "some updated email", external_id: "some updated external_id", external_provider: "some updated external_provider", name: "some updated name"}
  @invalid_attrs %{background_color: nil, email: nil, external_id: nil, external_provider: nil, name: nil}

  defp create_instructor(_) do
    instructor = instructor_fixture()
    %{instructor: instructor}
  end

  describe "Index" do
    setup [:create_instructor]

    test "lists all instructors", %{conn: conn, instructor: instructor} do
      {:ok, _index_live, html} = live(conn, Routes.instructor_index_path(conn, :index))

      assert html =~ "Listing Instructors"
      assert html =~ instructor.background_color
    end

    test "saves new instructor", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.instructor_index_path(conn, :index))

      assert index_live |> element("a", "New Instructor") |> render_click() =~
               "New Instructor"

      assert_patch(index_live, Routes.instructor_index_path(conn, :new))

      assert index_live
             |> form("#instructor-form", instructor: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#instructor-form", instructor: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.instructor_index_path(conn, :index))

      assert html =~ "Instructor created successfully"
      assert html =~ "some background_color"
    end

    test "updates instructor in listing", %{conn: conn, instructor: instructor} do
      {:ok, index_live, _html} = live(conn, Routes.instructor_index_path(conn, :index))

      assert index_live |> element("#instructor-#{instructor.id} a", "Edit") |> render_click() =~
               "Edit Instructor"

      assert_patch(index_live, Routes.instructor_index_path(conn, :edit, instructor))

      assert index_live
             |> form("#instructor-form", instructor: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#instructor-form", instructor: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.instructor_index_path(conn, :index))

      assert html =~ "Instructor updated successfully"
      assert html =~ "some updated background_color"
    end

    test "deletes instructor in listing", %{conn: conn, instructor: instructor} do
      {:ok, index_live, _html} = live(conn, Routes.instructor_index_path(conn, :index))

      assert index_live |> element("#instructor-#{instructor.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#instructor-#{instructor.id}")
    end
  end

  describe "Show" do
    setup [:create_instructor]

    test "displays instructor", %{conn: conn, instructor: instructor} do
      {:ok, _show_live, html} = live(conn, Routes.instructor_show_path(conn, :show, instructor))

      assert html =~ "Show Instructor"
      assert html =~ instructor.background_color
    end

    test "updates instructor within modal", %{conn: conn, instructor: instructor} do
      {:ok, show_live, _html} = live(conn, Routes.instructor_show_path(conn, :show, instructor))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Instructor"

      assert_patch(show_live, Routes.instructor_show_path(conn, :edit, instructor))

      assert show_live
             |> form("#instructor-form", instructor: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#instructor-form", instructor: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.instructor_show_path(conn, :show, instructor))

      assert html =~ "Instructor updated successfully"
      assert html =~ "some updated background_color"
    end
  end
end
