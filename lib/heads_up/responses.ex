defmodule HeadsUp.Responses do
  @moduledoc """
  The Responses context.
  """

  import Ecto.Query, warn: false
  alias HeadsUp.Repo

  alias HeadsUp.Responses.Response
  alias HeadsUp.{Incidents.Incident, Incidents}
  alias HeadsUp.Accounts.User

  def list_responses do
    Repo.all(Response)
  end

  def get_response!(id), do: Repo.get!(Response, id)

  def create_response(%Incident{} = incident, %User{} = user, attrs \\ %{}) do
    %Response{incident: incident, user: user}
    |> IO.inspect()
    |> Response.changeset(attrs)
    |> Repo.insert()
    |> case  do
      {:ok, response} -> 
        Incidents.broadcast(incident.id, {:response_created, response})
        {:ok,  response}
      {:error, _} = error ->
        error
    end
  end

  def update_response(%Response{} = response, attrs) do
    response
    |> Response.changeset(attrs)
    |> Repo.update()
  end

  def delete_response(%Response{} = response) do
    Repo.delete(response)
  end

  def change_response(%Response{} = response, attrs \\ %{}) do
    Response.changeset(response, attrs)
  end
end
