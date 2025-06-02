defmodule HeadsUpWeb.AdminIncidentLive.Index do
  use HeadsUpWeb, :live_view
  alias HeadsUp.Incidents.Incident
  alias HeadsUp.Admin
  import  HeadsUpWeb.CustomComponents

  def mount(_params, _session, socket) do
    socket = socket
      |> assign(:page_title, "Admin incidents")
      |> stream(:incidents, Admin.list_incidents())
    {:ok, socket}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    incident = Admin.get_incident!(id)
    Admin.delete_incident!(incident)
    {:noreply, stream_delete(socket, :incidents, incident)}
  end

  def render(assigns) do
    ~H"""
    <div class="admin-index">
      <.header>
        {@page_title}
        <:actions>
          <.link navigate={~p"/admin/incidents/add"}>
            <.button type="button">
                Create
            </.button>
          </.link>
        </:actions>
      </.header>
      <.table id="admin-incidents" rows={@streams.incidents}>
        <:col :let={{_dom_id, incident}} label="name">
          {incident.name}
        </:col>
        <:col :let={{_dom_id, incident}} label="status">
          <.badge status={incident.status} />
        </:col>
        <:col :let={{_dom_id, incident}} label="priority">
          {incident.priority}
        </:col>
        <:action :let={{_dom_id, incident}}>
          <.link navigate={~p"/admin/incidents/#{incident}/edit"}>
            edit
          </.link>
        </:action>
        <:action :let={{_dom_id, incident}}>
          <.link
            phx-click="delete"
            phx-value-id={incident.id}
            data-confirm={"Are you sure to delete: `#{incident.name}` incident?"}>
            <.icon name="hero-trash" class="h-4 w-4" />
          </.link>
        </:action>
      </.table>
    </div>
    """
  end
end
