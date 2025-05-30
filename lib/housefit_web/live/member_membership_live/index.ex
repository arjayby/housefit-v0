defmodule HousefitWeb.MemberMembershipLive.Index do
  use HousefitWeb, :live_view

  alias Housefit.Gym

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Member memberships
        <:actions>
          <.button variant="primary" navigate={~p"/member_memberships/new"}>
            <.icon name="hero-plus" /> New Member membership
          </.button>
        </:actions>
      </.header>

      <.table
        id="member_memberships"
        rows={@streams.member_memberships}
        row_click={fn {_id, member_membership} -> JS.navigate(~p"/member_memberships/#{member_membership}") end}
      >
        <:col :let={{_id, member_membership}} label="Start date">{member_membership.start_date}</:col>
        <:col :let={{_id, member_membership}} label="End date">{member_membership.end_date}</:col>
        <:col :let={{_id, member_membership}} label="Sessions remaining">{member_membership.sessions_remaining}</:col>
        <:col :let={{_id, member_membership}} label="Sessions total">{member_membership.sessions_total}</:col>
        <:col :let={{_id, member_membership}} label="Status">{member_membership.status}</:col>
        <:col :let={{_id, member_membership}} label="Payment amount">{member_membership.payment_amount}</:col>
        <:col :let={{_id, member_membership}} label="Payment date">{member_membership.payment_date}</:col>
        <:col :let={{_id, member_membership}} label="Notes">{member_membership.notes}</:col>
        <:action :let={{_id, member_membership}}>
          <div class="sr-only">
            <.link navigate={~p"/member_memberships/#{member_membership}"}>Show</.link>
          </div>
          <.link navigate={~p"/member_memberships/#{member_membership}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, member_membership}}>
          <.link
            phx-click={JS.push("delete", value: %{id: member_membership.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Gym.subscribe_member_memberships(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Member memberships")
     |> stream(:member_memberships, Gym.list_member_memberships(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    member_membership = Gym.get_member_membership!(socket.assigns.current_scope, id)
    {:ok, _} = Gym.delete_member_membership(socket.assigns.current_scope, member_membership)

    {:noreply, stream_delete(socket, :member_memberships, member_membership)}
  end

  @impl true
  def handle_info({type, %Housefit.Gym.MemberMembership{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :member_memberships, Gym.list_member_memberships(socket.assigns.current_scope), reset: true)}
  end
end
