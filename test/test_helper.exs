:ok = Application.ensure_started(:poolboy)
:ok = Application.ensure_started(:decimal)
:ok = Application.ensure_started(:postgrex)
:ok = Application.ensure_started(:ecto)

ExUnit.start

opts = [hostname: "localhost",
   username: "postgres", database: "geo_postgrex_test",
   extensions: [{Geo.PostGIS.Extension, library: Geo}]]

{:ok, pid} = Postgrex.Connection.start_link(opts)
{:ok, _} = Postgrex.Connection.query(pid, "CREATE EXTENSION IF NOT EXISTS postgis", [])
