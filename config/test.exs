use Mix.Config

config :geo, Geo.Ecto.Test.Repo,
  database: "geo_postgrex_test",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  encoder:  &Geo.PostGIS.encoder/3, 
  decoder:  &Geo.PostGIS.decoder/4,
  formatter: &Geo.PostGIS.formatter/1

# Print only warnings and errors during test
config :logger, level: :warn

