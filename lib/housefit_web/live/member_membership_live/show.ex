defmodule HousefitWeb.MemberMembershipLive.Show do
  use HousefitWeb, :live_view

  alias Housefit.Gym

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Member membership {@member_membership.id}
        <:subtitle>This is a member_membership record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/member_memberships"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/member_memberships/#{@member_membership}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit member_membership
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Start date">{@member_membership.start_date}</:item>
        <:item title="End date">{@member_membership.end_date}</:item>
        <:item title="Sessions remaining">{@member_membership.sessions_remaining}</:item>
        <:item title="Sessions total">{@member_membership.sessions_total}</:item>
        <:item title="Status">{@member_membership.status}</:item>
        <:item title="Payment amount">{@member_membership.payment_amount}</:item>
        <:item title="Payment date">{@member_membership.payment_date}</:item>
        <:item title="Notes">{@member_membership.notes}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Gym.subscribe_member_memberships(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Member membership")
     |> assign(:member_membership, Gym.get_member_membership!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %Housefit.Gym.MemberMembership{id: id} = member_membership},
        %{assigns: %{member_membership: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :member_membership, member_membership)}
  end

  def handle_info(
        {:deleted, %Housefit.Gym.MemberMembership{id: id}},
        %{assigns: %{member_membership: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current member_membership was deleted.")
     |> push_navigate(to: ~p"/member_memberships")}
  end

  def handle_info({type, %Housefit.Gym.MemberMembership{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
