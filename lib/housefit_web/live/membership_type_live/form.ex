defmodule HousefitWeb.MembershipTypeLive.Form do
  use HousefitWeb, :live_view

  alias Housefit.Gym
  alias Housefit.Gym.MembershipType

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage membership_type records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="membership_type-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" />
        <.input
          field={@form[:type]}
          type="select"
          label="Type"
          prompt="Choose a value"
          options={Ecto.Enum.values(Housefit.Gym.MembershipType, :type)}
        />
        <.input field={@form[:duration_months]} type="number" label="Duration months" />
        <.input field={@form[:session_count]} type="number" label="Session count" />
        <.input field={@form[:price]} type="number" label="Price" step="any" />
        <.input field={@form[:description]} type="textarea" label="Description" />
        <.input field={@form[:is_active]} type="checkbox" label="Is active" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Membership type</.button>
          <.button navigate={return_path(@current_scope, @return_to, @membership_type)}>Cancel</.button>
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
    membership_type = Gym.get_membership_type!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Membership type")
    |> assign(:membership_type, membership_type)
    |> assign(:form, to_form(Gym.change_membership_type(socket.assigns.current_scope, membership_type)))
  end

  defp apply_action(socket, :new, _params) do
    membership_type = %MembershipType{user_id: socket.assigns.current_scope.user.id}

    socket
    |> assign(:page_title, "New Membership type")
    |> assign(:membership_type, membership_type)
    |> assign(:form, to_form(Gym.change_membership_type(socket.assigns.current_scope, membership_type)))
  end

  @impl true
  def handle_event("validate", %{"membership_type" => membership_type_params}, socket) do
    changeset = Gym.change_membership_type(socket.assigns.current_scope, socket.assigns.membership_type, membership_type_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"membership_type" => membership_type_params}, socket) do
    save_membership_type(socket, socket.assigns.live_action, membership_type_params)
  end

  defp save_membership_type(socket, :edit, membership_type_params) do
    case Gym.update_membership_type(socket.assigns.current_scope, socket.assigns.membership_type, membership_type_params) do
      {:ok, membership_type} ->
        {:noreply,
         socket
         |> put_flash(:info, "Membership type updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, membership_type)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_membership_type(socket, :new, membership_type_params) do
    case Gym.create_membership_type(socket.assigns.current_scope, membership_type_params) do
      {:ok, membership_type} ->
        {:noreply,
         socket
         |> put_flash(:info, "Membership type created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, membership_type)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _membership_type), do: ~p"/membership_types"
  defp return_path(_scope, "show", membership_type), do: ~p"/membership_types/#{membership_type}"
end
