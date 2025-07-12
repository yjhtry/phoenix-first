defmodule HeadsUpWeb.Router do
  use HeadsUpWeb, :router

  import HeadsUpWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {HeadsUpWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
    plug :snoop
  end

  def snoop(conn, _opts) do
    answer = ~w(Yes No Maybe) |> Enum.random()

    assign(conn, :answer, answer)
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", HeadsUpWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/welcome", WelcomeController, :index
    get "/tips", TipController, :index
    get "/tips/:id", TipController, :show

    live_session :public,
      on_mount: {HeadsUpWeb.UserAuth, :mount_current_user} do
      live "/effort", EffortLive
      live "/incidents", IncidentLive.Index
      live "/incidents/:id", IncidentLive.Show
    end
  end

  scope "/", HeadsUpWeb do
    pipe_through [:browser, :require_admin_user]

    live_session :admin,
      on_mount: {HeadsUpWeb.UserAuth, :ensure_admin} do
      live "/admin/incidents", AdminIncidentLive.Index
      live "/admin/incidents/add", AdminIncidentLive.Form, :new
      live "/admin/incidents/:id/edit", AdminIncidentLive.Form, :edit

      live "/admin/categories", AdminCategoryLive.Index, :index
      live "/admin/categories/new", AdminCategoryLive.Index, :new
      live "/admin/categories/:id/edit", AdminCategoryLive.Index, :edit
      live "/admin/categories/:id", AdminCategoryLive.Show, :show
      live "/admin/categories/:id/show/edit", AdminCategoryLive.Show, :edit

      live "/admin/users", AdminUserLive.Index
    end
  end

  # Other scopes may use custom stacks.
  scope "/api", HeadsUpWeb.Api do
    pipe_through :api

    get "/incidents", IncidentController, :index
    post "/incidents", IncidentController, :create
    get "/incidents/:id", IncidentController, :show
    get "/categories/:id/incidents", CategoryController, :show

    get "/admin/incidents/export", IncidentController, :export
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:heads_up, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: HeadsUpWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", HeadsUpWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{HeadsUpWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", HeadsUpWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{HeadsUpWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", HeadsUpWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{HeadsUpWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
