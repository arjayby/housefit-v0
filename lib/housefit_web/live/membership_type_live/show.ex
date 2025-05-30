defmodule HousefitWeb.MembershipTypeLive.Show do
  use HousefitWeb, :live_view

  alias Housefit.Gym

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Membership type {@membership_type.id}
        <:subtitle>This is a membership_type record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/dashboard/membership_types"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button
            variant="primary"
            navigate={~p"/dashboard/membership_types/#{@membership_type}/edit?return_to=show"}
          >
            <.icon name="hero-pencil-square" /> Edit membership_type
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@membership_type.name}</:item>
        <:item title="Type">{@membership_type.type}</:item>
        <:item title="Duration months">{@membership_type.duration_months}</:item>
        <:item title="Session count">{@membership_type.session_count}</:item>
        <:item title="Price">{@membership_type.price}</:item>
        <:item title="Description">{@membership_type.description}</:item>
        <:item title="Is active">{@membership_type.is_active}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Gym.subscribe_membership_types(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Membership type")
     |> assign(:membership_type, Gym.get_membership_type!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %Housefit.Gym.MembershipType{id: id} = membership_type},
        %{assigns: %{membership_type: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :membership_type, membership_type)}
  end

  def handle_info(
        {:deleted, %Housefit.Gym.MembershipType{id: id}},
        %{assigns: %{membership_type: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current membership_type was deleted.")
     |> push_navigate(to: ~p"/dashboard/membership_types")}
  end

  def handle_info({type, %Housefit.Gym.MembershipType{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
