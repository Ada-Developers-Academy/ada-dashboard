defmodule DashboardWeb.Router do
  use DashboardWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {DashboardWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", DashboardWeb do
    pipe_through :browser

    get "/", PageController, :index

    get "/instructors/colors.css", InstructorController, :colors
    live "/instructors", InstructorLive.Index, :index
    live "/instructors/:id/edit", InstructorLive.Index, :edit
    live "/instructors/:id", InstructorLive.Show, :show
    live "/instructors/:id/show/edit", InstructorLive.Show, :edit

    live "/cohorts", CohortLive.Index, :index
    live "/cohorts/new", CohortLive.Index, :new
    live "/cohorts/:id/edit", CohortLive.Index, :edit
    live "/cohorts/:id", CohortLive.Show, :show
    live "/cohorts/:id/show/edit", CohortLive.Show, :edit

    live "/campus", CampusLive.Index, :index
    live "/campus/new", CampusLive.Index, :new
    live "/campus/:id/edit", CampusLive.Index, :edit
    live "/campus/:id", CampusLive.Show, :show
    live "/campus/:id/show/edit", CampusLive.Show, :edit

    live "/calendars", CalendarLive.Index, :index
    live "/calendars/:id", CalendarLive.Show, :show
    live "/events/:id", EventLive.Show, :show

    # TODO: Require relationship with cohort and campus
    live "/classes", ClassLive.Index, :index
    live "/classes/new", ClassLive.Index, :new
    live "/classes/:id/edit", ClassLive.Index, :edit
    live "/classes/:id", ClassLive.Show, :show
    live "/classes/:id/show/edit", ClassLive.Show, :edit
  end

  scope "/auth", DashboardWeb do
    pipe_through :browser

    get "/:provider/callback", AuthController, :callback
    get "/:provider", AuthController, :index
    get "/:provider/logout", AuthController, :logout
  end

  # Other scopes may use custom stacks.
  # scope "/api", DashboardWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: DashboardWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
