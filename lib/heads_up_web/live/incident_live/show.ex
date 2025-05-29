defmodule HeadsUpWeb.IncidentLive.Show do
  use HeadsUpWeb, :live_view
  alias HeadsUp.Incidents
  import HeadsUpWeb.CustomComponents

  def mount(%{"id" => id}, _session, socket) do
    incident = Incidents.get_incident(id)
    urgent_incidents = Incidents.list_incidents()
      |> Enum.filter(&(&1.id != String.to_integer(id)))

    socket = assign(
      socket,
      incident: incident,
      page_title: incident.name,
      urgent_incidents: urgent_incidents
    )

    {:ok, socket}
  end
  
  def render(assigns) do
    IO.inspect([self(), 'Show render'])
    ~H"""
    <div class="incident-show">
      <div class="incident">
        <img src={@incident.image_path} />
        <section>
          <.badge status={@incident.status} />
          <header>
            <h2>{@incident.name}</h2>
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
    </div>
    """
  end

  def urgent_incidents(assigns) do
    ~H"""
    <section>
      <h4>Urgent Incidents</h4>
      <ul class="incidents">
        <li :for={incident <- @incidents}>
          <img src={incident.image_path} /> {incident.name}
        </li>
      </ul>
    </section>
    """
  end
end
