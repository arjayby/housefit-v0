defmodule HousefitWeb.Router do
  use HousefitWeb, :router

  import HousefitWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {HousefitWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", HousefitWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Other scopes may use custom stacks.
  # scope "/api", HousefitWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:housefit, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: HousefitWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", HousefitWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{HousefitWeb.UserAuth, :require_authenticated}] do
      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email
    end

    post "/users/update-password", UserSessionController, :update_password
  end

  scope "/dashboard", HousefitWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :default,
      root_layout: {HousefitWeb.Layouts, :dashboard},
      on_mount: [{HousefitWeb.UserAuth, :require_authenticated}] do
      live "/members", MemberLive.Index, :index
      live "/members/new", MemberLive.Form, :new
      live "/members/:id", MemberLive.Show, :show
      live "/members/:id/edit", MemberLive.Form, :edit

      live "/member_memberships", MemberMembershipLive.Index, :index
      live "/member_memberships/new", MemberMembershipLive.Form, :new
      live "/member_memberships/:id", MemberMembershipLive.Show, :show
      live "/member_memberships/:id/edit", MemberMembershipLive.Form, :edit

      live "/membership_types", MembershipTypeLive.Index, :index
      live "/membership_types/new", MembershipTypeLive.Form, :new
      live "/membership_types/:id", MembershipTypeLive.Show, :show
      live "/membership_types/:id/edit", MembershipTypeLive.Form, :edit

      live "/gym_sessions", GymSessionLive.Index, :index
      live "/gym_sessions/new", GymSessionLive.Form, :new
      live "/gym_sessions/:id", GymSessionLive.Show, :show
      live "/gym_sessions/:id/edit", GymSessionLive.Form, :edit
    end
  end

  scope "/", HousefitWeb do
    pipe_through [:browser]

    live_session :current_user,
      on_mount: [{HousefitWeb.UserAuth, :mount_current_scope}] do
      live "/users/register", UserLive.Registration, :new
      live "/users/log-in", UserLive.Login, :new
      live "/users/log-in/:token", UserLive.Confirmation, :new
    end

    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end
end
