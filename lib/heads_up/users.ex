defmodule HeadsUp.Users do
  alias HeadsUp.Accounts.User
  alias HeadsUp.Repo

  def get_user!(id) do
    Repo.get!(User, id)
  end

  def list_users() do
    Repo.all(User)
  end

  def toggle_admin(%User{} = user, is_admin) do
    Repo.update(Ecto.Changeset.change(user, %{is_admin: is_admin}))
  end
end
