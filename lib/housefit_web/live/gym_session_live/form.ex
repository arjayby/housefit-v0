defmodule HousefitWeb.GymSessionLive.Form do
  use HousefitWeb, :live_view

  alias Housefit.Gym
  alias Housefit.Gym.GymSession

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage gym_session records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="gym_session-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:check_in_time]} type="datetime-local" label="Check in time" />
        <.input field={@form[:check_out_time]} type="datetime-local" label="Check out time" />
        <.input field={@form[:session_date]} type="date" label="Session date" />
        <.input field={@form[:notes]} type="textarea" label="Notes" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Gym session</.button>
          <.button navigate={return_path(@current_scope, @return_to, @gym_session)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    gym_session = Gym.get_gym_session!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Gym session")
    |> assign(:gym_session, gym_session)
    |> assign(:form, to_form(Gym.change_gym_session(socket.assigns.current_scope, gym_session)))
  end

  defp apply_action(socket, :new, _params) do
    gym_session = %GymSession{user_id: socket.assigns.current_scope.user.id}

    socket
    |> assign(:page_title, "New Gym session")
    |> assign(:gym_session, gym_session)
    |> assign(:form, to_form(Gym.change_gym_session(socket.assigns.current_scope, gym_session)))
  end

  @impl true
  def handle_event("validate", %{"gym_session" => gym_session_params}, socket) do
    changeset =
      Gym.change_gym_session(
        socket.assigns.current_scope,
        socket.assigns.gym_session,
        gym_session_params
      )

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"gym_session" => gym_session_params}, socket) do
    save_gym_session(socket, socket.assigns.live_action, gym_session_params)
  end

  defp save_gym_session(socket, :edit, gym_session_params) do
    case Gym.update_gym_session(
           socket.assigns.current_scope,
           socket.assigns.gym_session,
           gym_session_params
         ) do
      {:ok, gym_session} ->
        {:noreply,
         socket
         |> put_flash(:info, "Gym session updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, gym_session)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_gym_session(socket, :new, gym_session_params) do
    case Gym.create_gym_session(socket.assigns.current_scope, gym_session_params) do
      {:ok, gym_session} ->
        {:noreply,
         socket
         |> put_flash(:info, "Gym session created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, gym_session)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _gym_session), do: ~p"/dashboard/gym_sessions"
  defp return_path(_scope, "show", gym_session), do: ~p"/dashboard/gym_sessions/#{gym_session}"
end
