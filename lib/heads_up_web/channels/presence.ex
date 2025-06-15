defmodule HeadsUpWeb.Presence do
  @moduledoc """
  Provides presence tracking to channels and processes.

  See the [`Phoenix.Presence`](https://hexdocs.pm/phoenix/Phoenix.Presence.html)
  docs for more details.
  """
  use Phoenix.Presence,
    otp_app: :heads_up,
    pubsub_server: HeadsUp.PubSub


  def init(_opts) do
    {:ok, %{}}
  end

  def handle_metas(topic, %{joins: joins, leaves: leaves}, presences, state) do
    for {username, _presence} <- joins do
      presence = %{id: username, metas: Map.fetch!(presences, username)}
      msg = {:user_joined, presence}

      Phoenix.PubSub.local_broadcast(HeadsUp.PubSub, "update" <> topic, msg)
    end

    for {username, _presence} <- leaves do
      metas = case Map.fetch(presences, username) do
        {:ok, metas} -> metas
        :error -> []
      end

      presence = %{id: username, metas: metas}
      msg = {:user_leaved, presence}

      Phoenix.PubSub.local_broadcast(HeadsUp.PubSub, "update" <> topic, msg)
    end

    {:ok, state}
  end
end
