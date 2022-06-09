defmodule Geo.WKT.Test do
  use ExUnit.Case, async: false
  use ExUnitProperties

  test "Encode Point to WKT" do
    geom = %Geo.Point{coordinates: {30, -90}}
    assert(Geo.WKT.encode!(geom) == "POINT(30 -90)")
  end

  test "Decode WKT to Point" do
    point = Geo.WKT.decode!("POINT(30 -90)")
    assert(point.coordinates == {30, -90})
  end

  test "Encode PointZ to WKT" do
    geom = %Geo.PointZ{coordinates: {30, -90, 0}}
    assert(Geo.WKT.encode!(geom) == "POINT Z(30 -90 0)")
  end

  test "Decode WKT to PointZ" do
    point = Geo.WKT.decode!("POINT Z(30 -90 0)")
    assert(point.coordinates == {30, -90, 0})
  end

  test "Encode PointM to WKT" do
    geom = %Geo.PointM{coordinates: {30, -90, 0}}
    assert(Geo.WKT.encode!(geom) == "POINT M(30 -90 0)")
  end

  test "Decode WKT to PointM" do
    point = Geo.WKT.decode!("POINT M(30 -90 0)")
    assert(point.coordinates == {30, -90, 0})
  end

  test "Encode PointZM to WKT" do
    geom = %Geo.PointZM{coordinates: {30, -90, 0, 45}}
    assert(Geo.WKT.encode!(geom) == "POINT ZM(30 -90 0 45)")
  end

  test "Decode WKT to PointZM" do
    point = Geo.WKT.decode!("POINT ZM(30 -90 0 45)")
    assert(point.coordinates == {30, -90, 0, 45})
  end

  test "Decode EWKT to Point" do
    point = Geo.WKT.decode!("SRID=4326;POINT(30 -90)")
    assert(point.coordinates == {30, -90})
    assert(point.srid == 4326)
  end

  test "Encode Linestring to WKT" do
    geom = %Geo.LineString{coordinates: [{30, 10}, {10, 30}, {40, 40}]}
    assert(Geo.WKT.encode!(geom) == "LINESTRING(30 10,10 30,40 40)")
  end

  test "Decode WKT to Linestring" do
    geom = Geo.WKT.decode!("LINESTRING(30 10,10 30,40 40)")
    assert(geom.coordinates == [{30, 10}, {10, 30}, {40, 40}])
  end

  test "Encode Polygon to WKT" do
    geom = %Geo.Polygon{
      coordinates: [
        [{35, 10}, {45, 45}, {15, 40}, {10, 20}, {35, 10}],
        [{20, 30}, {35, 35}, {30, 20}, {20, 30}]
      ]
    }

    assert(
      Geo.WKT.encode!(geom) ==
        "POLYGON((35 10,45 45,15 40,10 20,35 10),(20 30,35 35,30 20,20 30))"
    )
  end

  test "Encode Polygon to EWKT" do
    geom = %Geo.Polygon{
      coordinates: [
        [{35, 10}, {45, 45}, {15, 40}, {10, 20}, {35, 10}],
        [{20, 30}, {35, 35}, {30, 20}, {20, 30}]
      ],
      srid: 4326
    }

    assert(
      Geo.WKT.encode!(geom) ==
        "SRID=4326;POLYGON((35 10,45 45,15 40,10 20,35 10),(20 30,35 35,30 20,20 30))"
    )
  end

  test "Decode WKT to Polygon" do
    geom = Geo.WKT.decode!("POLYGON((35 10,45 45,15 40,10 20,35 10))")
    assert(geom.coordinates == [[{35, 10}, {45, 45}, {15, 40}, {10, 20}, {35, 10}]])
  end

  test "Decode WKT to Polygon 2" do
    geom = Geo.WKT.decode!("POLYGON((35 10,45 45,15 40,10 20,35 10),(20 30,35 35,30 20,20 30))")

    assert(
      geom.coordinates == [
        [{35, 10}, {45, 45}, {15, 40}, {10, 20}, {35, 10}],
        [{20, 30}, {35, 35}, {30, 20}, {20, 30}]
      ]
    )
  end

  test "Decode WKT with spaces between exterior and holes to Polygon 2" do
    geom = Geo.WKT.decode!("POLYGON((35 10,45 45,15 40,10 20,35 10), (20 30,35 35,30 20,20 30))")

    assert(
      geom.coordinates == [
        [{35, 10}, {45, 45}, {15, 40}, {10, 20}, {35, 10}],
        [{20, 30}, {35, 35}, {30, 20}, {20, 30}]
      ]
    )
  end

  test "Encode MultiPoint to WKT" do
    geom = %Geo.MultiPoint{coordinates: [{0, 0}, {20, 20}, {60, 60}]}
    assert(Geo.WKT.encode!(geom) == "MULTIPOINT(0 0,20 20,60 60)")
  end

  test "Decode WKT to MultiPoint" do
    geom = Geo.WKT.decode!("MULTIPOINT(0 0,20 20,60 60)")
    assert(geom.coordinates == [{0, 0}, {20, 20}, {60, 60}])
  end

  test "Decode EWKT to MultiPoint" do
    geom = Geo.WKT.decode!("SRID=4326;MULTIPOINT(0 0,20 20,60 60)")
    assert(geom.coordinates == [{0, 0}, {20, 20}, {60, 60}])
    assert(geom.srid == 4326)
  end

  test "Encode MultiPointM to WKT" do
    geom = %Geo.MultiPointM{coordinates: [{0, 0, 100}, {20, 20, 200}]}
    assert(Geo.WKT.encode!(geom) == "MULTIPOINTM(0 0 100,20 20 200)")
  end

  test "Decode WKT to MultiPointM" do
    geom = Geo.WKT.decode!("MULTIPOINTM(0 0 100,20 20 200)")
    assert(geom.coordinates == [{0, 0, 100}, {20, 20, 200}])
  end

  test "Decode EWKT to MultiPointM" do
    geom = Geo.WKT.decode!("SRID=4326;MULTIPOINTM(0 0 100,20 20 200)")
    assert(geom.coordinates == [{0, 0, 100}, {20, 20, 200}])
    assert(geom.srid == 4326)
  end

  test "Encode MultiLineString to WKT" do
    geom = %Geo.MultiLineString{
      coordinates: [[{10, 10}, {20, 20}, {10, 40}], [{40, 40}, {30, 30}, {40, 20}, {30, 10}]]
    }

    assert(
      Geo.WKT.encode!(geom) == "MULTILINESTRING((10 10,20 20,10 40),(40 40,30 30,40 20,30 10))"
    )
  end

  test "Decode WKT to MultiLineString" do
    geom = Geo.WKT.decode!("MULTILINESTRING((10 10,20 20,10 40),(40 40,30 30,40 20,30 10))")

    assert(
      geom.coordinates == [
        [{10, 10}, {20, 20}, {10, 40}],
        [{40, 40}, {30, 30}, {40, 20}, {30, 10}]
      ]
    )
  end

  test "Decode WKT with spaces between LineStrings to MultiLineString" do
    geom = Geo.WKT.decode!("MULTILINESTRING((10 10,20 20,10 40), (40 40,30 30,40 20,30 10))")

    assert(
      geom.coordinates == [
        [{10, 10}, {20, 20}, {10, 40}],
        [{40, 40}, {30, 30}, {40, 20}, {30, 10}]
      ]
    )
  end

  test "Decode EWKT to MultiLineString" do
    geom =
      Geo.WKT.decode!("SRID=4326;MULTILINESTRING((10 10,20 20,10 40),(40 40,30 30,40 20,30 10))")

    assert(
      geom.coordinates == [
        [{10, 10}, {20, 20}, {10, 40}],
        [{40, 40}, {30, 30}, {40, 20}, {30, 10}]
      ]
    )

    assert(geom.srid == 4326)
  end

  test "Encode MultiPolygon to WKT" do
    geom = %Geo.MultiPolygon{
      coordinates: [
        [[{40, 40}, {20, 45}, {45, 30}, {40, 40}]],
        [
          [{20, 35}, {10, 30}, {10, 10}, {30, 5}, {45, 20}, {20, 35}],
          [{30, 20}, {20, 15}, {20, 25}, {30, 20}]
        ]
      ]
    }

    assert(
      Geo.WKT.encode!(geom) ==
        "MULTIPOLYGON(((40 40,20 45,45 30,40 40)),((20 35,10 30,10 10,30 5,45 20,20 35),(30 20,20 15,20 25,30 20)))"
    )
  end

  test "Decode WKT to MultiPolygon" do
    geom =
      Geo.WKT.decode!(
        "MULTIPOLYGON(((40 40,20 45,45 30,40 40)),((20 35,10 30,10 10,30 5,45 20,20 35),(30 20,20 15,20 25,30 20)))"
      )

    assert(
      geom.coordinates == [
        [[{40, 40}, {20, 45}, {45, 30}, {40, 40}]],
        [
          [{20, 35}, {10, 30}, {10, 10}, {30, 5}, {45, 20}, {20, 35}],
          [{30, 20}, {20, 15}, {20, 25}, {30, 20}]
        ]
      ]
    )
  end

  test "Decode WKT with spaces between polygons to MultiPolygon" do
    geom =
      Geo.WKT.decode!(
        "MULTIPOLYGON(((40 40,20 45,45 30,40 40)), ((20 35,10 30,10 10,30 5,45 20,20 35), (30 20,20 15,20 25,30 20)))"
      )

    assert(
      geom.coordinates == [
        [[{40, 40}, {20, 45}, {45, 30}, {40, 40}]],
        [
          [{20, 35}, {10, 30}, {10, 10}, {30, 5}, {45, 20}, {20, 35}],
          [{30, 20}, {20, 15}, {20, 25}, {30, 20}]
        ]
      ]
    )
  end

  test "Decode EWKT to MultiPolygon" do
    geom =
      Geo.WKT.decode!(
        "SRID=4326;MULTIPOLYGON(((40 40,20 45,45 30,40 40)),((20 35,10 30,10 10,30 5,45 20,20 35),(30 20,20 15,20 25,30 20)))"
      )

    assert(
      geom.coordinates == [
        [[{40, 40}, {20, 45}, {45, 30}, {40, 40}]],
        [
          [{20, 35}, {10, 30}, {10, 10}, {30, 5}, {45, 20}, {20, 35}],
          [{30, 20}, {20, 15}, {20, 25}, {30, 20}]
        ]
      ]
    )

    assert(geom.srid == 4326)
  end

  test "Encode Geometry Collection to and from WKT" do
    wkt = "GEOMETRYCOLLECTION(POINT(4 6),LINESTRING(4 6,7 10))"
    geom = Geo.WKT.decode!(wkt)
    assert(Enum.count(geom.geometries) == 2)
    assert(Geo.WKT.encode!(geom) == wkt)
  end

  test "Encode Geometry Collection to and from EWKT" do
    ewkt = "SRID=4326;GEOMETRYCOLLECTION(POINT(4 6),LINESTRING(4 6,7 10))"
    geom = Geo.WKT.decode!(ewkt)
    assert(Enum.count(geom.geometries) == 2)
    assert(hd(geom.geometries).srid == 4326)
    assert(List.last(geom.geometries).srid == 4326)
    assert(Geo.WKT.encode!(geom) == ewkt)
  end

  test "make sure to not include SRID when srid is 0" do
    geom = %Geo.Point{coordinates: {30, -90}, srid: 0}
    assert(Geo.WKT.encode!(geom) == "POINT(30 -90)")
  end

  test "Encode Point to WKT using encode" do
    geom = %Geo.Point{coordinates: {30, -90}}
    assert {:ok, "POINT(30 -90)"} = Geo.WKT.encode(geom)
  end

  test "Decode WKT to Point using decode" do
    {:ok, point} = Geo.WKT.decode("POINT(30 -90)")
    assert(point.coordinates == {30, -90})
  end

  property "encodes and decodes back to the correct Point struct" do
    check all x <- float(),
              y <- float() do
      geom = %Geo.Point{coordinates: {x, y}}
      assert geom == Geo.WKT.encode!(geom) |> Geo.WKT.decode!()
    end
  end

  property "encodes and decodes back to the correct PointM struct" do
    check all x <- float(),
              y <- float(),
              m <- float() do
      geom = %Geo.PointM{coordinates: {x, y, m}}
      assert geom == Geo.WKT.encode!(geom) |> Geo.WKT.decode!()
    end
  end

  property "encodes and decodes back to the correct PointZ struct" do
    check all x <- float(),
              y <- float(),
              z <- float() do
      geom = %Geo.PointZ{coordinates: {x, y, z}}
      assert geom == Geo.WKT.encode!(geom) |> Geo.WKT.decode!()
    end
  end

  property "encodes and decodes back to the correct PointZM struct" do
    check all x <- float(),
              y <- float(),
              z <- float(),
              m <- float() do
      geom = %Geo.PointZM{coordinates: {x, y, z, m}}
      assert geom == Geo.WKT.encode!(geom) |> Geo.WKT.decode!()
    end
  end

  property "encodes and decodes back to the correct LineString struct" do
    check all list <- list_of({float(), float()}, min_length: 1) do
      geom = %Geo.LineString{coordinates: list}
      assert geom == Geo.WKT.encode!(geom) |> Geo.WKT.decode!()
    end
  end

  property "encodes and decodes back to the correct LineStringZ struct" do
    check all list <- list_of({float(), float(), float()}, min_length: 1) do
      geom = %Geo.LineStringZ{coordinates: list}
      assert geom == Geo.WKT.encode!(geom) |> Geo.WKT.decode!()
    end
  end
end
