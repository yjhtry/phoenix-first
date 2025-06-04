defmodule HeadsUpWeb.IncidentLive.Show do
  use HeadsUpWeb, :live_view
  alias HeadsUp.Incidents
  import HeadsUpWeb.CustomComponents

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _url, socket) do
    incident = Incidents.get_incident!(id)

    socket = socket
      |> assign(incident: incident, page_title: incident.name)
      |> assign_async(:urgent_incidents, fn -> {:ok, %{urgent_incidents: Incidents.urgent_incidents(incident)}} end)

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="incident-show">
      <div class="incident">
        <img src={@incident.image_path} />
        <section>
          <.badge status={@incident.status} />
          <header>
            <div>
              <h2>{@incident.name}</h2>
              <h3>{@incident.category.name}</h3>
            </div>
            <div class="priority">
              {@incident.priority}
            </div>
          </header>
          <div class="description">
            {@incident.description}
          </div>
        </section>
      </div>
      <div class="activity">
        <div class="left"></div>
        <div class="right">
          <.urgent_incidents incidents={@urgent_incidents} />
        </div>
      </div>
      <.back navigate={~p"/incidents"}>All Incidents</.back>
    </div>
    """
  end

  def urgent_incidents(assigns) do
    ~H"""
    <section>
      <h4>Urgent Incidents</h4>
      <.async_result :let={result} assign={@incidents}>
        <:loading>
          <div class="loading">
            <div class="spinner" />
          </div>
        </:loading>
        <:failed :let={reason}>
          <div class="failed">
            Whoops: {reason}
          </div>
        </:failed>
        <ul class="incidents">
          <li :for={incident <- result}>
            <.link navigate={~p"/incidents/#{incident.id}"}>
              <img src={incident.image_path} /> {incident.name}
            </.link>
          </li>
        </ul>
      </.async_result>
    </section>
    """
  end
end
