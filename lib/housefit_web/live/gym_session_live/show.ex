defmodule HousefitWeb.GymSessionLive.Show do
  use HousefitWeb, :live_view

  alias Housefit.Gym

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Gym session {@gym_session.id}
        <:subtitle>This is a gym_session record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/gym_sessions"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/gym_sessions/#{@gym_session}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit gym_session
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Check in time">{@gym_session.check_in_time}</:item>
        <:item title="Check out time">{@gym_session.check_out_time}</:item>
        <:item title="Session date">{@gym_session.session_date}</:item>
        <:item title="Notes">{@gym_session.notes}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Gym.subscribe_gym_sessions(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Gym session")
     |> assign(:gym_session, Gym.get_gym_session!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %Housefit.Gym.GymSession{id: id} = gym_session},
        %{assigns: %{gym_session: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :gym_session, gym_session)}
  end

  def handle_info(
        {:deleted, %Housefit.Gym.GymSession{id: id}},
        %{assigns: %{gym_session: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current gym_session was deleted.")
     |> push_navigate(to: ~p"/gym_sessions")}
  end

  def handle_info({type, %Housefit.Gym.GymSession{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
