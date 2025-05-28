defmodule HousefitWeb.MemberLive.Form do
  use HousefitWeb, :live_view

  alias Housefit.Gym
  alias Housefit.Gym.Member

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage member records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="member-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:email]} type="text" label="Email" />
        <.input field={@form[:first_name]} type="text" label="First name" />
        <.input field={@form[:last_name]} type="text" label="Last name" />
        <.input field={@form[:is_active]} type="checkbox" label="Is active" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Member</.button>
          <.button navigate={return_path(@current_scope, @return_to, @member)}>Cancel</.button>
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
    member = Gym.get_member!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Member")
    |> assign(:member, member)
    |> assign(:form, to_form(Gym.change_member(socket.assigns.current_scope, member)))
  end

  defp apply_action(socket, :new, _params) do
    member = %Member{user_id: socket.assigns.current_scope.user.id}

    socket
    |> assign(:page_title, "New Member")
    |> assign(:member, member)
    |> assign(:form, to_form(Gym.change_member(socket.assigns.current_scope, member)))
  end

  @impl true
  def handle_event("validate", %{"member" => member_params}, socket) do
    changeset = Gym.change_member(socket.assigns.current_scope, socket.assigns.member, member_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"member" => member_params}, socket) do
    save_member(socket, socket.assigns.live_action, member_params)
  end

  defp save_member(socket, :edit, member_params) do
    case Gym.update_member(socket.assigns.current_scope, socket.assigns.member, member_params) do
      {:ok, member} ->
        {:noreply,
         socket
         |> put_flash(:info, "Member updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, member)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_member(socket, :new, member_params) do
    case Gym.create_member(socket.assigns.current_scope, member_params) do
      {:ok, member} ->
        {:noreply,
         socket
         |> put_flash(:info, "Member created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, member)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _member), do: ~p"/members"
  defp return_path(_scope, "show", member), do: ~p"/members/#{member}"
end
