defmodule HeadsUpWeb.WelcomeController do
  use HeadsUpWeb, :controller

  def index(conn, _params) do
    render(conn, :index, page_title: "Welcome")
  end
end
