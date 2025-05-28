defmodule HousefitWeb.MemberLiveTest do
  use HousefitWeb.ConnCase

  import Phoenix.LiveViewTest
  import Housefit.GymFixtures

  @create_attrs %{email: "some email", first_name: "some first_name", last_name: "some last_name", is_active: true}
  @update_attrs %{email: "some updated email", first_name: "some updated first_name", last_name: "some updated last_name", is_active: false}
  @invalid_attrs %{email: nil, first_name: nil, last_name: nil, is_active: false}

  setup :register_and_log_in_user

  defp create_member(%{scope: scope}) do
    member = member_fixture(scope)

    %{member: member}
  end

  describe "Index" do
    setup [:create_member]

    test "lists all members", %{conn: conn, member: member} do
      {:ok, _index_live, html} = live(conn, ~p"/members")

      assert html =~ "Listing Members"
      assert html =~ member.email
    end

    test "saves new member", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/members")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Member")
               |> render_click()
               |> follow_redirect(conn, ~p"/members/new")

      assert render(form_live) =~ "New Member"

      assert form_live
             |> form("#member-form", member: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#member-form", member: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/members")

      html = render(index_live)
      assert html =~ "Member created successfully"
      assert html =~ "some email"
    end

    test "updates member in listing", %{conn: conn, member: member} do
      {:ok, index_live, _html} = live(conn, ~p"/members")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#members-#{member.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/members/#{member}/edit")

      assert render(form_live) =~ "Edit Member"

      assert form_live
             |> form("#member-form", member: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#member-form", member: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/members")

      html = render(index_live)
      assert html =~ "Member updated successfully"
      assert html =~ "some updated email"
    end

    test "deletes member in listing", %{conn: conn, member: member} do
      {:ok, index_live, _html} = live(conn, ~p"/members")

      assert index_live |> element("#members-#{member.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#members-#{member.id}")
    end
  end

  describe "Show" do
    setup [:create_member]

    test "displays member", %{conn: conn, member: member} do
      {:ok, _show_live, html} = live(conn, ~p"/members/#{member}")

      assert html =~ "Show Member"
      assert html =~ member.email
    end

    test "updates member and returns to show", %{conn: conn, member: member} do
      {:ok, show_live, _html} = live(conn, ~p"/members/#{member}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/members/#{member}/edit?return_to=show")

      assert render(form_live) =~ "Edit Member"

      assert form_live
             |> form("#member-form", member: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#member-form", member: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/members/#{member}")

      html = render(show_live)
      assert html =~ "Member updated successfully"
      assert html =~ "some updated email"
    end
  end
end
