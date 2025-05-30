defmodule HousefitWeb.MemberLive.Show do
  use HousefitWeb, :live_view

  alias Housefit.Gym

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Member {@member.id}
        <:subtitle>This is a member record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/dashboard/members"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/dashboard/members/#{@member}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit member
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Email">{@member.email}</:item>
        <:item title="First name">{@member.first_name}</:item>
        <:item title="Last name">{@member.last_name}</:item>
        <:item title="Is active">{@member.is_active}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Gym.subscribe_members(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Member")
     |> assign(:member, Gym.get_member!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %Housefit.Gym.Member{id: id} = member},
        %{assigns: %{member: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :member, member)}
  end

  def handle_info(
        {:deleted, %Housefit.Gym.Member{id: id}},
        %{assigns: %{member: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current member was deleted.")
     |> push_navigate(to: ~p"/dashboard/members")}
  end

  def handle_info({type, %Housefit.Gym.Member{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
