defmodule HeadsUpWeb.IncidentLive.Show do
  use HeadsUpWeb, :live_view
  alias HeadsUp.{Incidents, Responses, Responses.Response}
  import HeadsUpWeb.CustomComponents

  def mount(_params, _session, socket) do
    response_change = Responses.change_response(%Response{})
    socket = socket
      |> assign(form: to_form(response_change))
    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _url, socket) do
    if connected?(socket) do
      Incidents.subscribe(id)
    end
    incident = Incidents.get_incident!(id)
    responses = Incidents.list_responses(incident)

    socket =
      socket
      |> assign(incident: incident, page_title: incident.name)
      |> stream(:responses, responses)
      |> assign(response_count: Enum.count(responses))
      |> assign_async(:urgent_incidents, fn ->
        {:ok, %{urgent_incidents: Incidents.urgent_incidents(incident)}}
      end)

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="incident-show">
      <.headline :if={@incident.heroic_response}>
        <.icon name="hero-sparkles-solid" />
        Heroic Responder: {@incident.heroic_response.user.username}
        <:tagline>
          {@incident.heroic_response.note}
        </:tagline>
      </.headline>
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
          <div class="totals">
            {@response_count} Responses
          </div>
          <div class="description">
            {@incident.description}
          </div>
        </section>
      </div>
      <div class="activity">
        <div class="left">
          <div :if={@incident.status == :pending}>
            <%= if @current_user do%>
              <.response_form form={@form} />
            <% else %>
              <.link href={~p"/users/log_in"} class="button">
                Log In To Post
              </.link>
            <% end %>
          </div>
          <div id="responses" phx-update="stream">
            <.response :for={{dom_id, response} <- @streams.responses} response={response} id={dom_id} />
          </div>
        </div>
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

  attr :form, Phoenix.HTML.Form, required: true

  def response_form(assigns) do
    ~H"""
    <.form for={@form} id="response-form" phx-submit="save" phx-change="validate">
      <.input
        field={@form[:status]}
        type="select"
        prompt="Choose a status"
        options={[:enroute, :arrived, :departed]}
      />

      <.input field={@form[:note]}
        type="textarea"
        phx-debounce="blur"
        placeholder="Note..."
        autofocus
      />

      <.button>Post</.button>
    </.form>
    """
  end

  attr :response, Response, required: true
  attr :id, :string, required: true

  def response(assigns) do
    ~H"""
    <div class="response" id={@id}>
      <span class="timeline"></span>
      <section>
        <div class="avatar">
          <.icon name="hero-user-solid" />
        </div>
        <div>
          <span class="username">
            {@response.user.username}
          </span>
          <span>
            {@response.status}
          </span>
          <blockquote>
            {@response.note}
          </blockquote>
        </div>
      </section>
    </div>
    """
  end

  def handle_event("validate", %{"response" => params}, socket) do
    response_change = Responses.change_response(%Response{}, params)

    socket = socket
      |> assign(form: to_form(response_change, action: :validate))
    {:noreply, socket}
  end

  def handle_event("save", %{"response" => params}, socket) do
    %{incident: incident, current_user: user } = socket.assigns

    case Responses.create_response(incident, user, params) do
      {:ok, _response} -> 
        changeset = Responses.change_response(%Response{})
        {:noreply, assign(socket, :form, to_form(changeset))}
      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def handle_info({:response_created, response}, socket) do
    socket = socket
      |> update(:response_count, &(&1 + 1))
      |> stream_insert(:responses, response, at: 0)
    {:noreply, socket}
  end

  def handle_info({:incident_updated, incident}, socket) do
    socket = socket
      |> assign(page_title: incident.name)
      |> assign(:incident, incident)
    {:noreply, socket}
  end
end
