defmodule Geo.Geography.Test do
  use ExUnit.Case, async: true

  setup do
    opts = [hostname: "localhost",
    username: "postgres", database: "geo_postgrex_test",
    extensions: [{Geo.PostGIS.Extension, library: Geo}]]

    {:ok, pid} = Postgrex.Connection.start_link(opts)
    {:ok, _result} = Postgrex.Connection.query(pid, "DROP TABLE IF EXISTS geography_test", [])
    {:ok, [pid: pid]}
  end

  test "insert geography point", context do
    pid = context[:pid]
    geo = %Geo.Point{ coordinates: {30, -90}, srid: 4326}
    {:ok, _} = Postgrex.Connection.query(pid, "CREATE TABLE geography_test (id int, geom geography(Point, 4326))", [])
    {:ok, _} = Postgrex.Connection.query(pid, "INSERT INTO geography_test VALUES ($1, $2)", [42, geo])
    {:ok, result} = Postgrex.Connection.query(pid, "SELECT * FROM geography_test", [])
    assert(result.rows == [{42, geo}])
  end
end
