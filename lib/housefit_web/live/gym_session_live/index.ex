defmodule HousefitWeb.GymSessionLive.Index do
  use HousefitWeb, :live_view

  alias Housefit.Gym

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Gym sessions
        <:actions>
          <.button variant="primary" navigate={~p"/dashboard/gym_sessions/new"}>
            <.icon name="hero-plus" /> New Gym session
          </.button>
        </:actions>
      </.header>

      <.table
        id="gym_sessions"
        rows={@streams.gym_sessions}
        row_click={
          fn {_id, gym_session} -> JS.navigate(~p"/dashboard/gym_sessions/#{gym_session}") end
        }
      >
        <:col :let={{_id, gym_session}} label="Check in time">{gym_session.check_in_time}</:col>
        <:col :let={{_id, gym_session}} label="Check out time">{gym_session.check_out_time}</:col>
        <:col :let={{_id, gym_session}} label="Session date">{gym_session.session_date}</:col>
        <:col :let={{_id, gym_session}} label="Notes">{gym_session.notes}</:col>
        <:action :let={{_id, gym_session}}>
          <div class="sr-only">
            <.link navigate={~p"/dashboard/gym_sessions/#{gym_session}"}>Show</.link>
          </div>
          <.link navigate={~p"/dashboard/gym_sessions/#{gym_session}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, gym_session}}>
          <.link
            phx-click={JS.push("delete", value: %{id: gym_session.id}) |> hide("##{id}")}
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
      Gym.subscribe_gym_sessions(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Gym sessions")
     |> stream(:gym_sessions, Gym.list_gym_sessions(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    gym_session = Gym.get_gym_session!(socket.assigns.current_scope, id)
    {:ok, _} = Gym.delete_gym_session(socket.assigns.current_scope, gym_session)

    {:noreply, stream_delete(socket, :gym_sessions, gym_session)}
  end

  @impl true
  def handle_info({type, %Housefit.Gym.GymSession{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply,
     stream(socket, :gym_sessions, Gym.list_gym_sessions(socket.assigns.current_scope),
       reset: true
     )}
  end
end
