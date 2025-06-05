defmodule HeadsUpWeb.Api.CategoryController do
  use HeadsUpWeb, :controller

  alias HeadsUp.Categories

  def show(conn, %{"id" => id}) do
    category = Categories.get_category_with_incidents!(id)

    render(conn, :show, category: category)
  end
end
