import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :dashboard, Dashboard.Repo,
  username: "postgres",
  password: "postgres",
  database: "dashboard_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :dashboard_web, DashboardWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "0zBQE8lRVSb3XDPsrkrlik22XoyHz9IveYJSZVbKgzxdUfXiZN+WqdGCoQ5ouAYe",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# In test we don't send emails.
config :dashboard, Dashboard.Mailer, adapter: Swoosh.Adapters.Test

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
