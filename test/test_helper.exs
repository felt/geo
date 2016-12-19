:ok = Application.ensure_started(:poolboy)
:ok = Application.ensure_started(:decimal)
:ok = Application.ensure_started(:connection)
:ok = Application.ensure_started(:db_connection)
:ok = Application.ensure_started(:postgrex)
:ok = Application.ensure_started(:ecto)

defmodule Geo.Test.Helper do
  def opts do
    [hostname: "localhost",
     username: "postgres", database: "geo_postgrex_test",
     types: Geo.PostGIS.PostgrexTypes
    ]
  end
end

ExUnit.start
