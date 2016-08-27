defmodule Geo.Geography.Test do
  use ExUnit.Case, async: true

  setup do
    {:ok, pid} = Postgrex.start_link(Geo.Test.Helper.opts)
    {:ok, _result} = Postgrex.query(pid, "DROP TABLE IF EXISTS geography_test", [])
    {:ok, [pid: pid]}
  end

  test "insert geography point", context do
    pid = context[:pid]
    geo = %Geo.Point{ coordinates: {30, -90}, srid: 4326}
    {:ok, _} = Postgrex.query(pid, "CREATE TABLE geography_test (id int, geom geography(Point, 4326))", [])
    {:ok, _} = Postgrex.query(pid, "INSERT INTO geography_test VALUES ($1, $2)", [42, geo])
    {:ok, result} = Postgrex.query(pid, "SELECT * FROM geography_test", [])
    assert(result.rows == [[42, geo]])
  end
end
