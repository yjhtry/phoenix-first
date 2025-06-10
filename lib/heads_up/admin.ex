defmodule HeadsUp.Admin do
  alias HeadsUp.{Incidents.Incident, Incidents}
  alias HeadsUp.Repo
  import Ecto.Query

  def list_incidents do
    Incident
    |> preload(:heroic_response)
    |> order_by(desc: :updated_at)
    |> Repo.all()
  end

  def incident_change(%Incident{} = incident, attrs \\ %{}) do
    Incident.changeset(incident, attrs)
  end

  def create_incident(%Incident{} = incident, attr \\ %{}) do
    incident_change(incident, attr)
    |> Repo.insert()
  end

  def edit_incident(%Incident{} = incident, attr \\ %{}) do
    incident_change(incident, attr)
    |> Repo.update()
    |> case  do
      {:ok, incident} -> 
        incident = Repo.preload(incident, [:category, heroic_response: :user])
        Incidents.broadcast(incident.id, {:incident_updated, incident})
        {:ok, incident}
      {:error, _} = error -> error
    end
  end

  def get_incident!(id) do
    Repo.get!(Incident, id)
  end

  def delete_incident!(%Incident{} = incident) do
    Repo.delete!(incident)
  end

  def draw_heroic_response(%Incident{status: :resolved} = incident) do
    incident = Repo.preload(incident, [:responses])
    case incident.responses do
      [] -> {:error, "No response to draw!"}
      responses -> 
        response = Enum.random(responses)
        edit_incident(incident, %{heroic_response_id: response.id})
    end
  end

  def draw_heroic_response(%Incident{}) do
    {:error, "Incident must be resolved to draw a heroic response!"}
  end
end
