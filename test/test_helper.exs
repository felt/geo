ExUnit.start

opts = [hostname: "localhost",
   username: "postgres", database: "geo_postgrex_test",
   extensions: [{Geo.PostGIS.Extension, library: Geo}]]

{:ok, pid} = Postgrex.Connection.start_link(opts)
{:ok, _} = Postgrex.Connection.query(pid, "CREATE EXTENSION IF NOT EXISTS postgis", [])

