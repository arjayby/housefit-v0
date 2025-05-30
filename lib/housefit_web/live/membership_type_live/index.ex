defmodule HousefitWeb.MembershipTypeLive.Index do
  use HousefitWeb, :live_view

  alias Housefit.Gym

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Membership types
        <:actions>
          <.button variant="primary" navigate={~p"/dashboard/membership_types/new"}>
            <.icon name="hero-plus" /> New Membership type
          </.button>
        </:actions>
      </.header>

      <.table
        id="membership_types"
        rows={@streams.membership_types}
        row_click={
          fn {_id, membership_type} ->
            JS.navigate(~p"/dashboard/membership_types/#{membership_type}")
          end
        }
      >
        <:col :let={{_id, membership_type}} label="Name">{membership_type.name}</:col>
        <:col :let={{_id, membership_type}} label="Type">{membership_type.type}</:col>
        <:col :let={{_id, membership_type}} label="Duration months">
          {membership_type.duration_months}
        </:col>
        <:col :let={{_id, membership_type}} label="Session count">
          {membership_type.session_count}
        </:col>
        <:col :let={{_id, membership_type}} label="Price">{membership_type.price}</:col>
        <:col :let={{_id, membership_type}} label="Description">{membership_type.description}</:col>
        <:col :let={{_id, membership_type}} label="Is active">{membership_type.is_active}</:col>
        <:action :let={{_id, membership_type}}>
          <div class="sr-only">
            <.link navigate={~p"/dashboard/membership_types/#{membership_type}"}>Show</.link>
          </div>
          <.link navigate={~p"/dashboard/membership_types/#{membership_type}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, membership_type}}>
          <.link
            phx-click={JS.push("delete", value: %{id: membership_type.id}) |> hide("##{id}")}
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
      Gym.subscribe_membership_types(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Membership types")
     |> stream(:membership_types, Gym.list_membership_types(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    membership_type = Gym.get_membership_type!(socket.assigns.current_scope, id)
    {:ok, _} = Gym.delete_membership_type(socket.assigns.current_scope, membership_type)

    {:noreply, stream_delete(socket, :membership_types, membership_type)}
  end

  @impl true
  def handle_info({type, %Housefit.Gym.MembershipType{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply,
     stream(socket, :membership_types, Gym.list_membership_types(socket.assigns.current_scope),
       reset: true
     )}
  end
end
