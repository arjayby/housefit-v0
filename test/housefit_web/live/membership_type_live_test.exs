defmodule HousefitWeb.MembershipTypeLiveTest do
  use HousefitWeb.ConnCase

  import Phoenix.LiveViewTest
  import Housefit.GymFixtures

  @create_attrs %{
    name: "some name",
    type: :time_based,
    description: "some description",
    duration_months: 42,
    session_count: 42,
    price: "120.5",
    is_active: true
  }
  @update_attrs %{
    name: "some updated name",
    type: :session_based,
    description: "some updated description",
    duration_months: 43,
    session_count: 43,
    price: "456.7",
    is_active: false
  }
  @invalid_attrs %{
    name: nil,
    type: nil,
    description: nil,
    duration_months: nil,
    session_count: nil,
    price: nil,
    is_active: false
  }

  setup :register_and_log_in_user

  defp create_membership_type(%{scope: scope}) do
    membership_type = membership_type_fixture(scope)

    %{membership_type: membership_type}
  end

  describe "Index" do
    setup [:create_membership_type]

    test "lists all membership_types", %{conn: conn, membership_type: membership_type} do
      {:ok, _index_live, html} = live(conn, ~p"/dashboard/membership_types")

      assert html =~ "Listing Membership types"
      assert html =~ membership_type.name
    end

    test "saves new membership_type", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/dashboard/membership_types")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Membership type")
               |> render_click()
               |> follow_redirect(conn, ~p"/dashboard/membership_types/new")

      assert render(form_live) =~ "New Membership type"

      assert form_live
             |> form("#membership_type-form", membership_type: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#membership_type-form", membership_type: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/dashboard/membership_types")

      html = render(index_live)
      assert html =~ "Membership type created successfully"
      assert html =~ "some name"
    end

    test "updates membership_type in listing", %{conn: conn, membership_type: membership_type} do
      {:ok, index_live, _html} = live(conn, ~p"/dashboard/membership_types")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#membership_types-#{membership_type.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/dashboard/membership_types/#{membership_type}/edit")

      assert render(form_live) =~ "Edit Membership type"

      assert form_live
             |> form("#membership_type-form", membership_type: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#membership_type-form", membership_type: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/dashboard/membership_types")

      html = render(index_live)
      assert html =~ "Membership type updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes membership_type in listing", %{conn: conn, membership_type: membership_type} do
      {:ok, index_live, _html} = live(conn, ~p"/dashboard/membership_types")

      assert index_live
             |> element("#membership_types-#{membership_type.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#membership_types-#{membership_type.id}")
    end
  end

  describe "Show" do
    setup [:create_membership_type]

    test "displays membership_type", %{conn: conn, membership_type: membership_type} do
      {:ok, _show_live, html} = live(conn, ~p"/dashboard/membership_types/#{membership_type}")

      assert html =~ "Show Membership type"
      assert html =~ membership_type.name
    end

    test "updates membership_type and returns to show", %{
      conn: conn,
      membership_type: membership_type
    } do
      {:ok, show_live, _html} = live(conn, ~p"/dashboard/membership_types/#{membership_type}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(
                 conn,
                 ~p"/dashboard/membership_types/#{membership_type}/edit?return_to=show"
               )

      assert render(form_live) =~ "Edit Membership type"

      assert form_live
             |> form("#membership_type-form", membership_type: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#membership_type-form", membership_type: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/dashboard/membership_types/#{membership_type}")

      html = render(show_live)
      assert html =~ "Membership type updated successfully"
      assert html =~ "some updated name"
    end
  end
end
