defmodule HeadsUpWeb.AdminIncidentLive.Form do
  use HeadsUpWeb, :live_view
  alias HeadsUp.{Admin, Categories, Incidents, Incidents.Incident}

  def mount(params, _session, socket) do
    socket =
      socket
      |> assign(:status_options, Incidents.status())
      |> assign(:category_options, Categories.list_names_with_ids())
      |> apply_action(socket.assigns.live_action, params)

    {:ok, socket}
  end

  def apply_action(socket, :new, _params) do
    incident = %Incident{}
    changeset = Admin.incident_change(incident)

    socket
    |> assign(:form, to_form(changeset))
    |> assign(:incident, incident)
  end

  def apply_action(socket, :edit, %{"id" => id}) do
    incident = Admin.get_incident!(id)
    changeset = Admin.incident_change(incident)

    socket
    |> assign(:form, to_form(changeset))
    |> assign(:incident, incident)
  end

  def handle_event("submit", %{"incident" => params}, socket) do
    submit_incident(socket, socket.assigns.live_action, params)
  end

  def handle_event("validate", %{"incident" => params}, socket) do
    changeset = Admin.incident_change(socket.assigns.incident, params)

    socket =
      socket
      |> assign(:form, to_form(changeset, action: :validate))

    {:noreply, socket}
  end

  def submit_incident(socket, :new, params) do
    case Admin.create_incident(socket.assigns.incident, params) do
      {:ok, _incident} ->
        socket =
          socket
          |> put_flash(:info, "Incident Create Success!")
          |> push_navigate(to: ~p"/admin/incidents")

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  def submit_incident(socket, :edit, params) do
    case Admin.edit_incident(socket.assigns.incident, params) do
      {:ok, _incident} ->
        socket =
          socket
          |> put_flash(:info, "Incident Edit Success!")
          |> push_navigate(to: ~p"/admin/incidents")

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  def render(assigns) do
    ~H"""
    <.simple_form for={@form} id="incident-form" phx-submit="submit" phx-change="validate">
      <.input label="Name" type="text" field={@form[:name]} autocomplete="off" />
      <.input
        phx-debounce="blur"
        label="description"
        type="textarea"
        field={@form[:description]}
        autocomplete="off"
      />
      <.input label="Priority" type="number" field={@form[:priority]} min="1" />
      <.input label="status" type="select" field={@form[:status]} options={@status_options} />
      <.input
        label="Image Path"
        type="text"
        field={@form[:image_path]}
        value="/images/placeholder.jpg"
      />
      <.input label="Category" type="select" field={@form[:category_id]} options={@category_options} />
      <:actions>
        <.button phx-disable-with="Saving...">Submit</.button>
      </:actions>
    </.simple_form>
    """
  end
end
