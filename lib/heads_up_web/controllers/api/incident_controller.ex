defmodule HeadsUpWeb.Api.IncidentController do
  use HeadsUpWeb, :controller

  alias HeadsUp.Admin
  alias HeadsUp.Incidents.Incident
  alias HeadsUpWeb.Api.IncidentJSON

  def index(conn, _params) do
    incidents = Admin.list_incidents()
    render(conn, :index, incidents: incidents)
  end

  def show(conn, %{"id" => id}) do
    incident = Admin.get_incident!(id)
    render(conn, :show, incident: incident)
  end

  def create(conn, %{"incident" => incident}) do
    case Admin.create_incident(%Incident{}, incident) do
      {:ok, incident} ->
        json(conn, IncidentJSON.data(incident))

      {:error, %Ecto.Changeset{} = changeset} ->
        json(conn, Ecto.Changeset.traverse_errors(changeset, &translate_error/1))
    end
  end

  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", fn _ -> to_string(value) end)
    end)
  end

  def export(conn, _params) do
    data =
      Admin.list_incidents()
      |> CSV.encode(headers: [:name, :status, :priority, :description])
      |> Enum.to_list()

    conn |> send_download({:binary, data}, filename: "export.csv")
  end
end
