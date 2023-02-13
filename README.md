# Ada Dashboard #

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Create a `.env` with the environment variables mentioned below
  * Start Phoenix endpoint with `source .env && mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Requirements ##

* Elixir (`brew install elixir` on macOS)
* Postgres (`brew install postgres` on macOS)
* An [Internal Google OAuth Client ID](https://cloud.google.com/docs/authentication/api-keys) with "./auth/calendar" scope (this requires approval unless the app is marked as "internal").
  * You will need to go to "Enabled APIs & Services" and enable the Calendar API to be able to select the scope.
* The following environment variables to be set/exported:
  * `GOOGLE_CLIENT_ID` (from the Google Dashboard)
  * `GOOGLE_CLIENT_SECRET` (from the Google Dashboard)
  * `REDIRECT_URI` (Should `#{PROTOCOL}://#{HOST}:#{PORT}/auth/google/callback`, eg. `"http://localhost:4000/auth/google/callback"`)

Your `.env` file should look like this:

```bash
export GOOGLE_CLIENT_ID='my client id'
export GOOGLE_CLIENT_SECRET='my client secret'
export REDIRECT_URI="http://localhost:4000/auth/google/callback"
```

## Deploying ##

### Render.com ###

The application is already set up to deploy on [render.com](https://render.com).
It requires a PostgreSQL service and a Web Service.

#### Environment ####

The following environment variables need to be set:

* `DATABASE_URL` (from the PostgreSQL service instance)
* `ELIXIR_VERSION` should be set to a recent release (I used 1.4.2).
* `ERLANG_VERSION` should be set to a recent release (I used 25.1.2).
* `GOOGLE_CLIENT_ID` see above.
* `GOOGLE_CLIENT_SECRET` see above.
* `REDIRECT_URI` see above.
* `SECRET_KEY_BASE` should be the stored output of `mix phx.gen.secret`.

#### Settings ####

The "Build Command" should be set to:
```
./build.sh
```

The "Start Command" should be set to:
```
_build/prod/rel/dashboard/bin/dashboard eval Dashboard.Release.migrate && _build/prod/rel/dashboard/bin/dashboard start
```

All other settings can be left as their defaults.

### Resources ###

* [Phoenix deployment guides](https://hexdocs.pm/phoenix/deployment.html).
* [VS Code Elixir LS](https://github.com/elixir-lsp/vscode-elixir-ls)
* [Google API Authentication Keys](https://cloud.google.com/docs/authentication/api-keys)
