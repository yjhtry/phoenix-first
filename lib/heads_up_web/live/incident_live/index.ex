defmodule HeadsUpWeb.IncidentLive.Index do
  use HeadsUpWeb, :live_view

  alias HeadsUp.Incidents
  import HeadsUpWeb.CustomComponents

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    socket = socket
      |> assign(:page_title, "Incidents")
      |> assign(:form, to_form(params))
      |> stream(:incidents,  Incidents.filter_incidents(params), reset: true)

    {:noreply, socket}
  end

  def handle_event("filter", params, socket) do
    params = params
      |> Map.take(~w(q status sort_by))
      |> Map.reject(fn {_, v} -> v == "" end)

    {:noreply, push_patch(socket, to: ~p"/incidents?#{params}")}
  end

  def render(assigns) do
    ~H"""
    <div class="incident-index">
      <.headline>
        <.icon name="hero-trophy-mini" /> 25 Incidents Resolved This Month!
        <:tagline :let={vibe}>
          Thanks for pitching in. {vibe}
        </:tagline>
      </.headline>
      <.search_form form={@form} />
      <div class="incidents" id="incidents" phx-update="stream">
        <div id="empty" class="no-results only:block hidden">
          No raffles found. Try changing your filters.
        </div>
        <.incident_card
          :for={{dom_id, incident} <- @streams.incidents}
          incident={incident}
          id={dom_id}
        />
      </div>
    </div>
    """
  end

  attr :incident, HeadsUp.Incidents.Incident, required: true
  attr :rest, :global

  def incident_card(assigns) do
    ~H"""
    <.link navigate={~p"/incidents/#{@incident.id}"} {@rest}>
      <div class="card">
        <img src={@incident.image_path} />
        <h2>{@incident.name}</h2>
        <div class="details">
          <.badge status={@incident.status} />
          <div class="priority">
            {@incident.priority}
          </div>
        </div>
      </div>
    </.link>
    """
  end

  attr :form, Phoenix.HTML.Form, required: true

  def search_form(assigns) do
    assigns = assign(assigns, status_options: Incidents.status())

    ~H"""
    <div class="search">
      <.form for={@form} phx-change="filter" phx-submit="filter">
      <.input phx-debounce="500" field={@form[:q]} placeholder="Search..." autocomplete="off" />
      <.input
        type="select"
        field={@form[:status]}
        prompt="Status"
        options={@status_options}
      />
        <.input type="select" field={@form[:sort_by]} prompt="Sort By" options={[
          Name: "name",
          "Priority: High to Low": "priority_asc",
          "Priority: Low to High": "priority_desc"
        ]} />
        <.link patch={~p"/incidents"}>
          <.button type="button" >Reset</.button>
        </.link>
      </.form>
    </div>
    """
  end
end
