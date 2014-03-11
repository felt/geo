defmodule GeoWKBTest do
  use ExUnit.Case

  test "Decode WKB to Point" do
    point = Geo.WKB.decode("0101000000000000000000F03F000000000000F03F")
    assert(point.type == :point)
    assert(point.coordinates == [1, 1])
  end

  test "Decode EWKB to Point" do
    point = Geo.WKB.decode("0101000020E61000009EFB613A637B4240CF2C0950D3735EC0")
    assert(point.type == :point)
    assert(point.coordinates == [36.9639657, -121.8097725])
    assert(point.srid == 4326)
  end

  test "Encode Point to WKB" do
    geom = Geo.Geometry.new(type: :point, coordinates: [1, 1])
    assert(Geo.WKB.encode(geom, :ndr) == "0101000000000000000000F03F000000000000F03F")
  end

  test "Encode Point to EWKB" do
    geom = Geo.Geometry.new(type: :point, coordinates:  [36.9639657, -121.8097725], srid: 4326)
    assert(Geo.WKB.encode(geom, :ndr) == "0101000020E61000009EFB613A637B4240CF2C0950D3735EC0")
  end

end
