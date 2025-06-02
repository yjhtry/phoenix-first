defmodule HeadsUp.Admin do
  alias HeadsUp.Incidents.Incident
  alias HeadsUp.Repo
  import Ecto.Query
  import Ecto.Changeset

  def list_incidents do
    Incident
      |> order_by(desc: :inserted_at)
      |> Repo.all()
  end

  def incident_change(%Incident{} = incident, attr \\ %{}) do
    incident
      |> cast(attr, [:name, :description, :status, :priority, :image_path])
      |> validate_required([:name, :description, :status, :priority, :image_path])
      |> validate_length(:description, min: 10)
      |> validate_number(:priority, greater_than_or_equal_to: 1, less_than_or_equal_to: 3)
  end

  def add_incident(%Incident{} = incident, attr \\ %{}) do
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
