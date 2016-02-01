:ok = Application.ensure_started(:poolboy)
:ok = Application.ensure_started(:decimal)
:ok = Application.ensure_started(:connection)
:ok = Application.ensure_started(:db_connection)
:ok = Application.ensure_started(:postgrex)
:ok = Application.ensure_started(:ecto)

ExUnit.start

opts = [hostname: "localhost",
   username: "postgres", database: "geo_postgrex_test",
   extensions: [{Geo.PostGIS.Extension, library: Geo}]]

{:ok, pid} = Postgrex.start_link(opts)
{:ok, _} = Postgrex.query(pid, "CREATE EXTENSION IF NOT EXISTS postgis", [])
