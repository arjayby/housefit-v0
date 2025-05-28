defmodule HousefitWeb.MemberLive.Index do
  use HousefitWeb, :live_view

  alias Housefit.Gym

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Members
        <:actions>
          <.button variant="primary" navigate={~p"/members/new"}>
            <.icon name="hero-plus" /> New Member
          </.button>
        </:actions>
      </.header>

      <.table
        id="members"
        rows={@streams.members}
        row_click={fn {_id, member} -> JS.navigate(~p"/members/#{member}") end}
      >
        <:col :let={{_id, member}} label="Email">{member.email}</:col>
        <:col :let={{_id, member}} label="First name">{member.first_name}</:col>
        <:col :let={{_id, member}} label="Last name">{member.last_name}</:col>
        <:col :let={{_id, member}} label="Is active">{member.is_active}</:col>
        <:action :let={{_id, member}}>
          <div class="sr-only">
            <.link navigate={~p"/members/#{member}"}>Show</.link>
          </div>
          <.link navigate={~p"/members/#{member}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, member}}>
          <.link
            phx-click={JS.push("delete", value: %{id: member.id}) |> hide("##{id}")}
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
      Gym.subscribe_members(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Members")
     |> stream(:members, Gym.list_members(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    member = Gym.get_member!(socket.assigns.current_scope, id)
    {:ok, _} = Gym.delete_member(socket.assigns.current_scope, member)

    {:noreply, stream_delete(socket, :members, member)}
  end

  @impl true
  def handle_info({type, %Housefit.Gym.Member{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :members, Gym.list_members(socket.assigns.current_scope), reset: true)}
  end
end
