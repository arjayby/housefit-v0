defmodule HousefitWeb.MemberMembershipLive.Form do
  use HousefitWeb, :live_view

  alias Housefit.Gym
  alias Housefit.Gym.MemberMembership

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage member_membership records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="member_membership-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:start_date]} type="date" label="Start date" />
        <.input field={@form[:end_date]} type="date" label="End date" />
        <.input field={@form[:sessions_remaining]} type="number" label="Sessions remaining" />
        <.input field={@form[:sessions_total]} type="number" label="Sessions total" />
        <.input
          field={@form[:status]}
          type="select"
          label="Status"
          prompt="Choose a value"
          options={Ecto.Enum.values(Housefit.Gym.MemberMembership, :status)}
        />
        <.input field={@form[:payment_amount]} type="number" label="Payment amount" step="any" />
        <.input field={@form[:payment_date]} type="date" label="Payment date" />
        <.input field={@form[:notes]} type="textarea" label="Notes" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Member membership</.button>
          <.button navigate={return_path(@current_scope, @return_to, @member_membership)}>Cancel</.button>
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
    member_membership = Gym.get_member_membership!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Member membership")
    |> assign(:member_membership, member_membership)
    |> assign(:form, to_form(Gym.change_member_membership(socket.assigns.current_scope, member_membership)))
  end

  defp apply_action(socket, :new, _params) do
    member_membership = %MemberMembership{user_id: socket.assigns.current_scope.user.id}

    socket
    |> assign(:page_title, "New Member membership")
    |> assign(:member_membership, member_membership)
    |> assign(:form, to_form(Gym.change_member_membership(socket.assigns.current_scope, member_membership)))
  end

  @impl true
  def handle_event("validate", %{"member_membership" => member_membership_params}, socket) do
    changeset = Gym.change_member_membership(socket.assigns.current_scope, socket.assigns.member_membership, member_membership_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"member_membership" => member_membership_params}, socket) do
    save_member_membership(socket, socket.assigns.live_action, member_membership_params)
  end

  defp save_member_membership(socket, :edit, member_membership_params) do
    case Gym.update_member_membership(socket.assigns.current_scope, socket.assigns.member_membership, member_membership_params) do
      {:ok, member_membership} ->
        {:noreply,
         socket
         |> put_flash(:info, "Member membership updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, member_membership)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_member_membership(socket, :new, member_membership_params) do
    case Gym.create_member_membership(socket.assigns.current_scope, member_membership_params) do
      {:ok, member_membership} ->
        {:noreply,
         socket
         |> put_flash(:info, "Member membership created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, member_membership)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _member_membership), do: ~p"/member_memberships"
  defp return_path(_scope, "show", member_membership), do: ~p"/member_memberships/#{member_membership}"
end
