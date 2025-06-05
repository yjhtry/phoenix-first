defmodule HeadsUpWeb.Api.IncidentJSON do
  def index(%{incidents: incidents}) do
    %{incidents: for(incident <- incidents, do: data(incident))}
  end

  def show(%{incident: incident}) do
    %{incident: data(incident)}
  end

  def data(incident) do
    %{
      id: incident.id,
      name: incident.name,
      priority: incident.priority,
      status: incident.status,
      description: incident.description,
      category_id: incident.category_id
    }
  end
end
