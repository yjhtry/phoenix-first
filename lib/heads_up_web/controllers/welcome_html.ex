defmodule HeadsUpWeb.WelcomeHTML do
  use HeadsUpWeb, :html

  def index(assigns) do
    ~H"""
    <h1 class="text-3xl font-blod text-center">Welcome Heads Up</h1>
    """
  end
end
