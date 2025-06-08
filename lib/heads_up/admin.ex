defmodule HeadsUp.Admin do
  alias HeadsUp.Incidents.Incident
  alias HeadsUp.Repo
  import Ecto.Query

  def list_incidents do
    Incident
    |> order_by(desc: :inserted_at)
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
  end

  def get_incident!(id) do
    Repo.get!(Incident, id)
  end

  def delete_incident!(%Incident{} = incident) do
    Repo.delete!(incident)
  end
end
