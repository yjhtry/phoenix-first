defmodule HeadsUpWeb.AdminIncidentLive.Index do
  use HeadsUpWeb, :live_view
  alias HeadsUp.Admin
  import HeadsUpWeb.CustomComponents

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Admin incidents")
      |> stream(:incidents, Admin.list_incidents())

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="admin-index">
      <.button phx-click={JS.toggle(to: "#joke", in: "fade-in", out: "fade-out")}>
        Toggle Joke
      </.button>
      <div id="joke" class="joke hidden" phx-click={JS.toggle_class("blur")}>
        What can i say ? manba out!
      </div>
      <.header class="mt-6">
        {@page_title}
        <:actions>
          <.link navigate={~p"/admin/incidents/add"}>
            <.button type="button">
              Create
            </.button>
          </.link>
        </:actions>
      </.header>
      <.table
        id="admin-incidents"
        rows={@streams.incidents}
        row_click={fn {_dom_id, incident} -> JS.navigate(~p"/incidents/#{incident}") end}
      >
        <:col :let={{_dom_id, incident}} label="name">
          {incident.name}
        </:col>
        <:col :let={{_dom_id, incident}} label="status">
          <.badge status={incident.status} />
        </:col>
        <:col :let={{_dom_id, incident}} label="priority">
          {incident.priority}
        </:col>
        <:col :let={{_dom_id, incident}} label="heroic response">
          {incident.heroic_response && incident.heroic_response.id}
        </:col>
        <:action :let={{_dom_id, incident}}>
          <.link navigate={~p"/admin/incidents/#{incident}/edit"}>
            edit
          </.link>
        </:action>
        <:action :let={{dom_id, incident}}>
          <.link
            phx-click={delete_and_hide(dom_id, incident)}
            phx-value-id={incident.id}
            data-confirm={"Are you sure to delete: `#{incident.name}` incident?"}
          >
            <.icon name="hero-trash" class="h-4 w-4" />
          </.link>
        </:action>
        <:action :let={{_dom_id, incident}}>
          <.link phx-click="draw-response" phx-value-id={incident.id}>
            Draw Response
          </.link>
        </:action>
      </.table>
    </div>
    """
  end

  def handle_event("delete", %{"id" => id}, socket) do
    incident = Admin.get_incident!(id)
    Admin.delete_incident!(incident)
    {:noreply, stream_delete(socket, :incidents, incident)}
  end

  def handle_event("draw-response", %{"id" => id}, socket) do
    incident = Admin.get_incident!(id)

    case Admin.draw_heroic_response(incident) do
      {:ok, incident} ->
        socket =
          socket
          |> put_flash(:info, "Heroic response drawn!")
          |> stream_insert(:incidents, incident)

        {:noreply, socket}

      {:error, error} ->
        {:noreply, put_flash(socket, :error, error)}
    end
  end

  defp delete_and_hide(dom_id, incident) do
    JS.push("delete", value: %{"id" => incident.id})
    |> JS.hide(to: "##{dom_id}", transition: "fade-out")
  end
end
