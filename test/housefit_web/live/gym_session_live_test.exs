defmodule HousefitWeb.GymSessionLiveTest do
  use HousefitWeb.ConnCase

  import Phoenix.LiveViewTest
  import Housefit.GymFixtures

  @create_attrs %{check_in_time: "2025-05-29T06:25:00Z", check_out_time: "2025-05-29T06:25:00Z", session_date: "2025-05-29", notes: "some notes"}
  @update_attrs %{check_in_time: "2025-05-30T06:25:00Z", check_out_time: "2025-05-30T06:25:00Z", session_date: "2025-05-30", notes: "some updated notes"}
  @invalid_attrs %{check_in_time: nil, check_out_time: nil, session_date: nil, notes: nil}

  setup :register_and_log_in_user

  defp create_gym_session(%{scope: scope}) do
    gym_session = gym_session_fixture(scope)

    %{gym_session: gym_session}
  end

  describe "Index" do
    setup [:create_gym_session]

    test "lists all gym_sessions", %{conn: conn, gym_session: gym_session} do
      {:ok, _index_live, html} = live(conn, ~p"/gym_sessions")

      assert html =~ "Listing Gym sessions"
      assert html =~ gym_session.notes
    end

    test "saves new gym_session", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/gym_sessions")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Gym session")
               |> render_click()
               |> follow_redirect(conn, ~p"/gym_sessions/new")

      assert render(form_live) =~ "New Gym session"

      assert form_live
             |> form("#gym_session-form", gym_session: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#gym_session-form", gym_session: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/gym_sessions")

      html = render(index_live)
      assert html =~ "Gym session created successfully"
      assert html =~ "some notes"
    end

    test "updates gym_session in listing", %{conn: conn, gym_session: gym_session} do
      {:ok, index_live, _html} = live(conn, ~p"/gym_sessions")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#gym_sessions-#{gym_session.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/gym_sessions/#{gym_session}/edit")

      assert render(form_live) =~ "Edit Gym session"

      assert form_live
             |> form("#gym_session-form", gym_session: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#gym_session-form", gym_session: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/gym_sessions")

      html = render(index_live)
      assert html =~ "Gym session updated successfully"
      assert html =~ "some updated notes"
    end

    test "deletes gym_session in listing", %{conn: conn, gym_session: gym_session} do
      {:ok, index_live, _html} = live(conn, ~p"/gym_sessions")

      assert index_live |> element("#gym_sessions-#{gym_session.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#gym_sessions-#{gym_session.id}")
    end
  end

  describe "Show" do
    setup [:create_gym_session]

    test "displays gym_session", %{conn: conn, gym_session: gym_session} do
      {:ok, _show_live, html} = live(conn, ~p"/gym_sessions/#{gym_session}")

      assert html =~ "Show Gym session"
      assert html =~ gym_session.notes
    end

    test "updates gym_session and returns to show", %{conn: conn, gym_session: gym_session} do
      {:ok, show_live, _html} = live(conn, ~p"/gym_sessions/#{gym_session}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/gym_sessions/#{gym_session}/edit?return_to=show")

      assert render(form_live) =~ "Edit Gym session"

      assert form_live
             |> form("#gym_session-form", gym_session: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#gym_session-form", gym_session: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/gym_sessions/#{gym_session}")

      html = render(show_live)
      assert html =~ "Gym session updated successfully"
      assert html =~ "some updated notes"
    end
  end
end
