defmodule Geo.WKT.Test do
  use ExUnit.Case

  test "Encode Point to WKT" do
    geom = Geo.Geometry.new(type: :point, coordinates: [30, -90])
    assert(Geo.WKT.encode(geom) == "POINT(30 -90)")
  end

  test "Decode WKT to Point" do
    point = Geo.WKT.decode("POINT(30 -90)")
    assert(point.type == :point)
    assert(point.coordinates == [30, -90])
  end

  test "Decode EWKT to Point" do
    point = Geo.WKT.decode("SRID=4326;POINT(30 -90)")
    assert(point.type == :point)
    assert(point.coordinates == [30, -90])
    assert(point.srid == 4326)
  end

  test "Encode Linestring to WKT" do
    geom = Geo.Geometry.new(type: :line_string, coordinates: [[30, 10], [10, 30], [40, 40]])
    assert(Geo.WKT.encode(geom) == "LINESTRING(30 10, 10 30, 40 40)")
  end

  test "Decode WKT to Linestring" do
    point = Geo.WKT.decode("LINESTRING(30 10, 10 30, 40 40)")
    assert(point.type == :line_string)
    assert(point.coordinates == [[30, 10], [10, 30], [40, 40]])
  end

  test "Encode Polygon to WKT" do
    geom = Geo.Geometry.new(type: :polygon, coordinates: [ [[35, 10], [45, 45], [15, 40], [10, 20], [35, 10]], [[20, 30], [35, 35], [30, 20], [20, 30]] ])
    assert(Geo.WKT.encode(geom) == "POLYGON((35 10, 45 45, 15 40, 10 20, 35 10),(20 30, 35 35, 30 20, 20 30))")
  end

  test "Encode Polygon to EWKT" do
    geom = Geo.Geometry.new(type: :polygon, coordinates: [ [[35, 10], [45, 45], [15, 40], [10, 20], [35, 10]], [[20, 30], [35, 35], [30, 20], [20, 30]] ], srid: 4326)
    assert(Geo.WKT.encode(geom) == "SRID=4326;POLYGON((35 10, 45 45, 15 40, 10 20, 35 10),(20 30, 35 35, 30 20, 20 30))")
  end

  test "Decode WKT to Polygon" do
    point = Geo.WKT.decode("POLYGON((35 10, 45 45, 15 40, 10 20, 35 10))")
    assert(point.type == :polygon)
    assert(point.coordinates == [[[35, 10], [45, 45], [15, 40], [10, 20], [35, 10]]])
  end

  test "Decode WKT to Polygon 2" do
    point = Geo.WKT.decode("POLYGON((35 10, 45 45, 15 40, 10 20, 35 10),(20 30, 35 35, 30 20, 20 30))")
    assert(point.type == :polygon)
    assert(point.coordinates == [ [[35, 10], [45, 45], [15, 40], [10, 20], [35, 10]], [[20, 30], [35, 35], [30, 20], [20, 30]] ])
  end

  test "Encode MultiPoint to WKT" do
    geom = Geo.Geometry.new(type: :multi_point, coordinates: [[0, 0], [20, 20], [60, 60]])
    assert(Geo.WKT.encode(geom) == "MULTIPOINT(0 0, 20 20, 60 60)")
  end

  test "Decode WKT to MultiPoint" do
    point = Geo.WKT.decode("MULTIPOINT(0 0, 20 20, 60 60)")
    assert(point.type == :multi_point)
    assert(point.coordinates == [[0, 0], [20, 20], [60, 60]])
  end

  test "Decode EWKT to MultiPoint" do
    point = Geo.WKT.decode("SRID=4326;MULTIPOINT(0 0, 20 20, 60 60)")
    assert(point.type == :multi_point)
    assert(point.coordinates == [[0, 0], [20, 20], [60, 60]])
    assert(point.srid == 4326)
  end

end
