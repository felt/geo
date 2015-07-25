use Mix.Config

config :geo, Geo.Repo,
  database: "geo_postgrex_test",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  adapter: Ecto.Adapters.Postgres,
  extensions: [{Geo.PostGIS.Extension, library: Geo}]

# Print only warnings and errors during test
config :logger, level: :warn

