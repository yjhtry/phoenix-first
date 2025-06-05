defmodule HeadsUpWeb.Api.CategoryJSON do
  alias HeadsUpWeb.Api.IncidentJSON

  def show(%{category: category}) do
    %{
      category: %{
        id: category.id,
        name: category.name,
        slug: category.slug,
        incidents:
          for(
            incident <- category.incidents,
            do: IncidentJSON.data(incident)
          )
      }
    }
  end
end
