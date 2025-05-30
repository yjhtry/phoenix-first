defmodule HeadsUpWeb.CustomComponents do
  use HeadsUpWeb, :html

  attr :status, :atom, values: [:pending, :resolved, :canceled], default: :pending
  attr :class, :string, default: nil
  attr :rest, :global

  def badge(assigns) do
    ~H"""
    <div
      class={[
        "rounded-md px-2 py-1 text-xs font-medium uppercase inline-block border",
        @status == :pending && "text-lime-600 border-lime-600",
        @status == :resolved && "text-amber-600 border-amber-600",
        @status == :canceled && "text-gray-600 border-gray-600",
        @class
      ]}
      {@rest}
    >
      {@status}
    </div>
    """
  end

  slot :inner_block, required: true
  slot :tagline, required: true

  def headline(assigns) do
    assigns = assign(assigns, :emoji, ~w(👍 🙌 👊) |> Enum.random())

    ~H"""
    <div class="headline">
      <h1>{render_slot(@inner_block)}</h1>
      <div class="tagline">
        {render_slot(@tagline, @emoji)}
      </div>
    </div>
    """
  end
end
