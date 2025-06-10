defmodule HeadsUp.Incidents do
  alias HeadsUp.Incidents.Incident
  alias HeadsUp.Repo
  import Ecto.Query

  def list_incidents do
    Repo.all(Incident)
  end

  def filter_incidents(filter) do
    Incident
    |> with_status(filter["status"])
    |> search_by(filter["q"])
    |> with_category(filter["slug"])
    |> sort(filter["sort_by"])
    |> preload([:category])
    |> Repo.all()
  end

  defp with_status(query, status)
       when status in ~w(pending resolved canceled) do
    where(query, status: ^status)
  end

  defp with_status(query, _), do: query

  defp with_category(query, slug) when slug in ["", nil], do: query

  defp with_category(query, slug) do
    query
    |> join(:inner, [i], c in assoc(i, :category))
    |> where([_, c], c.slug == ^slug)
  end

  defp search_by(query, q) when q in ["", nil], do: query

  defp search_by(query, q) do
    where(query, [i], ilike(i.name, ^"%#{q}%"))
  end

  defp sort(query, "name") do
    order_by(query, :name)
  end

  defp sort(query, "priority_desc") do
    order_by(query, desc: :priority)
  end

  defp sort(query, "priority_asc") do
    order_by(query, asc: :priority)
  end

  defp sort(query, "category") do
    query
    |> join(:inner, [i], c in assoc(i, :category))
    |> order_by([_, c], c.name)
  end

  defp sort(query, _) do
    order_by(query, :id)
  end

  def get_incident!(id) do
    Incident |> preload([:category, heroic_response: :user]) |> Repo.get!(id)
  end

  def urgent_incidents(incident) do
    Incident
    |> where(status: :pending)
    |> where([i], i.id != ^incident.id)
    |> order_by(asc: :priority)
    |> limit(3)
    |> Repo.all()
  end

  def status() do
    Ecto.Enum.values(Incident, :status)
  end

  def list_responses(incident) do
    incident
    |> Ecto.assoc(:responses)
    |> preload(:user)
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  def subscribe(incident_id) do
    Phoenix.PubSub.subscribe(HeadsUp.PubSub, "incident:##{incident_id}")
  end

  def broadcast(incident_id, message) do
    Phoenix.PubSub.broadcast(HeadsUp.PubSub, "incident:##{incident_id}", message)
  end
end
