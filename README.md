# Ada Dashboard #

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Requirements ##

* Elixir (`brew install elixir` on macOS)
* Postgres (`brew install postgres` on macOS)
* Google API key with "calendar" scope (this requires approval unless the app is marked as "internal").
* The following environment variables to be set/exported:
  * `GOOGLE_CLIENT_ID` (from the Google Dashboard)
  * `GOOGLE_CLIENT_SECRET` (from the Google Dashboard)
  * `REDIRECT_URI` (Should `#{PROTOCOL}://#{HOST}:#{PORT}/auth/google/callback`, eg. `"http://localhost:4000/auth/google/callback"`)

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

