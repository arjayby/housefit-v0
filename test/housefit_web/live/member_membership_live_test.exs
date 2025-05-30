defmodule HousefitWeb.MemberMembershipLiveTest do
  use HousefitWeb.ConnCase

  import Phoenix.LiveViewTest
  import Housefit.GymFixtures

  @create_attrs %{status: :active, start_date: "2025-05-29", end_date: "2025-05-29", sessions_remaining: 42, sessions_total: 42, payment_amount: "120.5", payment_date: "2025-05-29", notes: "some notes"}
  @update_attrs %{status: :expired, start_date: "2025-05-30", end_date: "2025-05-30", sessions_remaining: 43, sessions_total: 43, payment_amount: "456.7", payment_date: "2025-05-30", notes: "some updated notes"}
  @invalid_attrs %{status: nil, start_date: nil, end_date: nil, sessions_remaining: nil, sessions_total: nil, payment_amount: nil, payment_date: nil, notes: nil}

  setup :register_and_log_in_user

  defp create_member_membership(%{scope: scope}) do
    member_membership = member_membership_fixture(scope)

    %{member_membership: member_membership}
  end

  describe "Index" do
    setup [:create_member_membership]

    test "lists all member_memberships", %{conn: conn, member_membership: member_membership} do
      {:ok, _index_live, html} = live(conn, ~p"/member_memberships")

      assert html =~ "Listing Member memberships"
      assert html =~ member_membership.notes
    end

    test "saves new member_membership", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/member_memberships")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Member membership")
               |> render_click()
               |> follow_redirect(conn, ~p"/member_memberships/new")

      assert render(form_live) =~ "New Member membership"

      assert form_live
             |> form("#member_membership-form", member_membership: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#member_membership-form", member_membership: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/member_memberships")

      html = render(index_live)
      assert html =~ "Member membership created successfully"
      assert html =~ "some notes"
    end

    test "updates member_membership in listing", %{conn: conn, member_membership: member_membership} do
      {:ok, index_live, _html} = live(conn, ~p"/member_memberships")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#member_memberships-#{member_membership.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/member_memberships/#{member_membership}/edit")

      assert render(form_live) =~ "Edit Member membership"

      assert form_live
             |> form("#member_membership-form", member_membership: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#member_membership-form", member_membership: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/member_memberships")

      html = render(index_live)
      assert html =~ "Member membership updated successfully"
      assert html =~ "some updated notes"
    end

    test "deletes member_membership in listing", %{conn: conn, member_membership: member_membership} do
      {:ok, index_live, _html} = live(conn, ~p"/member_memberships")

      assert index_live |> element("#member_memberships-#{member_membership.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#member_memberships-#{member_membership.id}")
    end
  end

  describe "Show" do
    setup [:create_member_membership]

    test "displays member_membership", %{conn: conn, member_membership: member_membership} do
      {:ok, _show_live, html} = live(conn, ~p"/member_memberships/#{member_membership}")

      assert html =~ "Show Member membership"
      assert html =~ member_membership.notes
    end

    test "updates member_membership and returns to show", %{conn: conn, member_membership: member_membership} do
      {:ok, show_live, _html} = live(conn, ~p"/member_memberships/#{member_membership}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/member_memberships/#{member_membership}/edit?return_to=show")

      assert render(form_live) =~ "Edit Member membership"

      assert form_live
             |> form("#member_membership-form", member_membership: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#member_membership-form", member_membership: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/member_memberships/#{member_membership}")

      html = render(show_live)
      assert html =~ "Member membership updated successfully"
      assert html =~ "some updated notes"
    end
  end
end
