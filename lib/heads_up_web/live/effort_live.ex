defmodule HeadsUpWeb.EffortLive do
  use HeadsUpWeb, :live_view

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Process.send_after(self(), :update, 2000)
    end
    socket = assign(socket,
      responders: 0,
      minutes_per_responder: 10,
      page_title: "Effort"
    )
    {:ok, socket}
  end 

  def render(assigns) do
    ~H"""
    <div class="effort">
      <h1>Community Love</h1>
      <section>
        <button phx-click="add" phx-value-quantity="3">+ 3</button>
        <div>{@responders}</div>
        &times;
        <form class="!mt-0" phx-change="recaculate">
          <input 
            name="minutes"
            value={@minutes_per_responder}
            type="number"
            phx-debounce="500"
            phx-throttle="500"
          />
        </form>
        =
        <div>{@responders * @minutes_per_responder}</div>
      </section>
    </div>
    """
  end

  def handle_event("add", %{"quantity" => quantity}, socket) do
    {:noreply, update(socket, :responders, &(&1 + String.to_integer(quantity)))}
  end

  def handle_event("recaculate", %{"minutes" => minutes}, socket) do
    {:noreply, assign(socket, :minutes_per_responder, String.to_integer(minutes))}
  end

  def handle_info(:update, socket) do
    Process.send_after(self(), :update, 2000)
    {:noreply, update(socket, :responders, &(&1 + 10))}
  end

end
