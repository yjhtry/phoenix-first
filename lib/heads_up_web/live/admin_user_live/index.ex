defmodule HeadsUpWeb.AdminUserLive.Index do
  use HeadsUpWeb, :live_view
  alias HeadsUp.Users

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(page_title: "User manage")
      |> stream(:users, Users.list_users())

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.table id="users-manage" rows={@streams.users}>
      <:col :let={{_dom_id, user}} label="Username">
        {user.username}
      </:col>
      <:col :let={{_dom_id, user}} label="Email">
        {user.email}
      </:col>
      <:col :let={{_dom_id, user}} label="IsAmin">
        {user.is_admin}
      </:col>
      <:action :let={{_dom_id, user}}>
        <.link
          phx-click="promote-admin"
          phx-value-id={user.id}
          data-confirm={
            if user.is_admin,
              do: "Are you are to remove admin permission",
              else: "Are you sure to add admin permission"
          }
        >
          Promote admin
        </.link>
      </:action>
    </.table>
    """
  end

  def handle_event("promote-admin", %{"id" => id}, socket) do
    user = Users.get_user!(id)

    case Users.toggle_admin(user, !user.is_admin) do
      {:ok, user} ->
        {:noreply, stream_insert(socket, :users, user)}

      {:error, _} ->
        socket = put_flash(socket, :error, "Promote admin falied!")
        {:noreply, socket}
    end
  end
end
