defmodule Geo.Contains.Test do
  use ExUnit.Case, async: true

  test "Point contains Point" do
    pointA = Geo.WKT.decode("SRID=4326;POINT(30 -90)")
    pointB = Geo.WKT.decode("POINT(30 -90)")
    pointC = Geo.WKT.decode("POINT(45 -90)")

    assert(Geo.contains(pointA, pointB) == true)
    assert(Geo.contains(pointA, pointA) == true)
    assert(Geo.contains(pointA, pointC) == false)
  end

  test "LineString contains Point" do
    lineA = Geo.WKT.decode("LINESTRING(30 -90, 31 -90)")
    pointA = Geo.WKT.decode("POINT(30 -90)")
    pointC = Geo.WKT.decode("POINT(45 -90)")

    assert(Geo.contains(lineA, pointA) == true)
    assert(Geo.contains(lineA, pointC) == false)
  end

end
