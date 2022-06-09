defmodule Geo.JSON.Test do
  use ExUnit.Case, async: true
  use ExUnitProperties

  doctest Geo.JSON

  test "Point to GeoJson Map" do
    geom = %Geo.Point{coordinates: {100.0, 0.0}}
    json = Geo.JSON.encode!(geom)

    assert json == %{"type" => "Point", "coordinates" => [100.0, 0.0]}
  end

  test "Point to GeoJson" do
    geom = %Geo.Point{coordinates: {100.0, 0.0}}
    json = Geo.JSON.encode!(geom) |> Jason.encode!()

    assert(json == "{\"coordinates\":[100.0,0.0],\"type\":\"Point\"}")
  end

  test "PointZ to GeoJson Map" do
    geom = %Geo.PointZ{coordinates: {100.0, 0.0, 70.0}}
    json = Geo.JSON.encode!(geom)

    assert json == %{"type" => "Point", "coordinates" => [100.0, 0.0, 70.0]}
  end

  test "PointZ to GeoJson" do
    geom = %Geo.PointZ{coordinates: {100.0, 0.0, 70.0}}
    json = Geo.JSON.encode!(geom) |> Jason.encode!()

    assert(json == "{\"coordinates\":[100.0,0.0,70.0],\"type\":\"Point\"}")
  end

  test "PointZ from GeoJson" do
    json = "{\"type\":\"Point\",\"coordinates\":[100.0,0.0,70.0]}"
    geom = Jason.decode!(json) |> Geo.JSON.decode!()

    assert(geom == %Geo.PointZ{coordinates: {100.0, 0.0, 70.0}})
  end

  test "LineString to GeoJson" do
    geom = %Geo.LineString{coordinates: [{100.0, 0.0}, {101.0, 1.0}]}
    json = Geo.JSON.encode!(geom) |> Jason.encode!()

    assert(json == "{\"coordinates\":[[100.0,0.0],[101.0,1.0]],\"type\":\"LineString\"}")
  end

  test "GeoJson to Point and back" do
    json = "{ \"type\": \"Point\", \"coordinates\": [100.0, 0.0] }"
    exjson = Jason.decode!(json)
    geom = Jason.decode!(json) |> Geo.JSON.decode!()

    assert(geom.coordinates == {100.0, 0.0})

    new_exjson = Geo.JSON.encode!(geom)
    assert(exjson == new_exjson)
  end

  test "GeoJson with SRID to Point and back" do
    json =
      "{\"type\":\"Point\",\"crs\":{\"type\":\"name\",\"properties\":{\"name\":\"EPSG:4326\"}},\"coordinates\":[100.0, 101.0]}"

    exjson = Jason.decode!(json)
    geom = Jason.decode!(json) |> Geo.JSON.decode!()

    assert(geom.coordinates == {100.0, 101.0})
    assert(geom.srid == 4326)

    new_exjson = Geo.JSON.encode!(geom)
    assert(exjson == new_exjson)
  end

  test "GeoJson to LineString and back" do
    json = "{ \"type\": \"LineString\", \"coordinates\": [ [100.0, 0.0], [101.0, 1.0] ]}"
    exjson = Jason.decode!(json)
    geom = Jason.decode!(json) |> Geo.JSON.decode!()

    assert(geom.coordinates == [{100.0, 0.0}, {101.0, 1.0}])
    new_exjson = Geo.JSON.encode!(geom)
    assert(exjson == new_exjson)
  end

  test "GeoJson to LineStringM and back" do
    json = "{ \"type\": \"LineStringM\", \"coordinates\": [ [100.0, 0.0, 50.0], [101.0, 1.0, 20.0] ]}"
    exjson = Jason.decode!(json)
    geom = Jason.decode!(json) |> Geo.JSON.decode!()

    assert(geom.coordinates == [{100.0, 0.0, 50.0}, {101.0, 1.0, 20.0}])
    new_exjson = Geo.JSON.encode!(geom)
    assert(exjson == new_exjson)
  end

  test "GeoJson to LineStringZ and back" do
    json = "{ \"type\": \"LineStringZ\", \"coordinates\": [ [100.0, 0.0, 50.0], [101.0, 1.0, 20.0] ]}"
    exjson = Jason.decode!(json)
    geom = Jason.decode!(json) |> Geo.JSON.decode!()

    assert(geom.coordinates == [{100.0, 0.0, 50.0}, {101.0, 1.0, 20.0}])
    new_exjson = Geo.JSON.encode!(geom)
    assert(exjson == new_exjson)
  end

  test "Throw altitude away and any extra elements from things other than points" do
    json =
      "{ \"type\": \"Polygon\", \"coordinates\": [[ [100.0, 0.0, 1.0, null], [101.0, 0.0, 1.0, null], [101.0, 1.0, 1.0, null], [100.0, 1.0, 1.0, null], [100.0, 0.0, 1.0, null] ]]}"

    geom = Jason.decode!(json) |> Geo.JSON.decode!()

    assert(
      geom.coordinates == [[{100.0, 0.0}, {101.0, 0.0}, {101.0, 1.0}, {100.0, 1.0}, {100.0, 0.0}]]
    )
  end

  test "GeoJson to Polygon and back" do
    json =
      "{ \"type\": \"Polygon\", \"coordinates\": [[ [100.0, 0.0], [101.0, 0.0], [101.0, 1.0], [100.0, 1.0], [100.0, 0.0] ]]}"

    exjson = Jason.decode!(json)
    geom = Jason.decode!(json) |> Geo.JSON.decode!()

    assert(
      geom.coordinates == [[{100.0, 0.0}, {101.0, 0.0}, {101.0, 1.0}, {100.0, 1.0}, {100.0, 0.0}]]
    )

    new_exjson = Geo.JSON.encode!(geom)
    assert(exjson == new_exjson)
  end

  test "GeoJson to MultiPoint and back" do
    json = "{ \"type\": \"MultiPoint\", \"coordinates\": [ [100.0, 0.0], [101.0, 1.0] ]}"
    exjson = Jason.decode!(json)
    geom = Jason.decode!(json) |> Geo.JSON.decode!()

    assert(geom.coordinates == [{100.0, 0.0}, {101.0, 1.0}])
    new_exjson = Geo.JSON.encode!(geom)
    assert(exjson == new_exjson)
  end

  test "GeoJson to MultiPointM and back" do
    json = "{ \"type\": \"MultiPointM\", \"coordinates\": [ [100.0, 0.0, 5], [101.0, 1.0, 50] ]}"
    exjson = Jason.decode!(json)
    geom = Jason.decode!(json) |> Geo.JSON.decode!()

    assert(geom.coordinates == [{100.0, 0.0, 5}, {101.0, 1.0, 50}])
    new_exjson = Geo.JSON.encode!(geom)
    assert(exjson == new_exjson)
  end

  test "GeoJson to MultiLineString and back" do
    json =
      "{ \"type\": \"MultiLineString\", \"coordinates\": [[ [100.0, 0.0], [101.0, 1.0] ],[ [102.0, 2.0], [103.0, 3.0] ]]}"

    exjson = Jason.decode!(json)
    geom = Jason.decode!(json) |> Geo.JSON.decode!()

    assert(geom.coordinates == [[{100.0, 0.0}, {101.0, 1.0}], [{102.0, 2.0}, {103.0, 3.0}]])
    new_exjson = Geo.JSON.encode!(geom)
    assert(exjson == new_exjson)
  end

  test "GeoJson to MultiPolygon and back" do
    json =
      "{ \"type\": \"MultiPolygon\", \"coordinates\": [[[[102.0, 2.0], [103.0, 2.0], [103.0, 3.0], [102.0, 3.0], [102.0, 2.0]]],[[[100.0, 0.0], [101.0, 0.0], [101.0, 1.0], [100.0, 1.0], [100.0, 0.0]],[[100.2, 0.2], [100.8, 0.2], [100.8, 0.8], [100.2, 0.8], [100.2, 0.2]]]]}"

    exjson = Jason.decode!(json)
    geom = Jason.decode!(json) |> Geo.JSON.decode!()

    assert(
      geom.coordinates == [
        [[{102.0, 2.0}, {103.0, 2.0}, {103.0, 3.0}, {102.0, 3.0}, {102.0, 2.0}]],
        [
          [{100.0, 0.0}, {101.0, 0.0}, {101.0, 1.0}, {100.0, 1.0}, {100.0, 0.0}],
          [{100.2, 0.2}, {100.8, 0.2}, {100.8, 0.8}, {100.2, 0.8}, {100.2, 0.2}]
        ]
      ]
    )

    new_exjson = Geo.JSON.encode!(geom)
    assert(exjson == new_exjson)
  end

  test "GeoJson to GeometryCollection and back" do
    json =
      "{ \"type\": \"GeometryCollection\",\"geometries\": [{ \"type\": \"Point\", \"coordinates\": [100.0, 0.0]},{ \"type\": \"LineString\",\"coordinates\": [ [101.0, 0.0], [102.0, 1.0] ]}]}"

    exjson = Jason.decode!(json)
    geom = Jason.decode!(json) |> Geo.JSON.decode!()

    assert(Enum.count(geom.geometries) == 2)

    new_exjson = Geo.JSON.encode!(geom)
    assert(exjson == new_exjson)
  end

  test "Unable to encode non-geo type" do
    assert_raise Geo.JSON.Encoder.EncodeError, fn ->
      Geo.JSON.encode!(%{a: "b"})
    end
  end

  test "Unable to decode invalid geojson map" do
    assert_raise Geo.JSON.Decoder.DecodeError, fn ->
      Geo.JSON.decode!(%{a: "b"})
    end
  end

  test "Gets srid value when just a number" do
    json = %{
      "type" => "Point",
      "coordinates" => [100.0, 0.0],
      "crs" => %{"type" => "name", "properties" => %{"name" => 4326}}
    }

    geom = Geo.JSON.decode!(json)

    assert geom.srid == 4326
  end

  test "decode/1" do
    valid_json = "{ \"type\": \"Point\", \"coordinates\": [100.0, 0.0] }"
    invalid_json = "{ \"type\": \"random_type\", \"coordinates\": [100.0, 0.0] }"

    assert {:ok, _value} = Jason.decode!(valid_json) |> Geo.JSON.decode()
    assert {:error, _error} = Jason.decode!(invalid_json) |> Geo.JSON.decode()
  end

  test "encode/1" do
    valid_geom = %Geo.LineString{coordinates: [{100.0, 0.0}, {101.0, 1.0}]}
    invalid_geom = %{random: 123}

    assert {:ok, _map} = Geo.JSON.encode(valid_geom)
    assert {:error, _error} = Geo.JSON.encode(invalid_geom)
  end

  test "Point with properties to GeoJson" do
    geom = %Geo.Point{coordinates: {100.0, 0.0}, properties: %{hi: "there"}}
    json = Geo.JSON.encode!(geom) |> Jason.encode!()

    assert(
      json == "{\"coordinates\":[100.0,0.0],\"properties\":{\"hi\":\"there\"},\"type\":\"Point\"}"
    )
  end

  test "GeoJson with properties to GeometryCollection and back" do
    json =
      "{\"properties\":{\"hi\":\"there\"}, \"type\": \"GeometryCollection\",\"geometries\": [{ \"type\": \"Point\", \"coordinates\": [100.0, 0.0]},{ \"type\": \"LineString\",\"coordinates\": [ [101.0, 0.0], [102.0, 1.0] ]}]}"

    exjson = Jason.decode!(json)
    geom = Jason.decode!(json) |> Geo.JSON.decode!()

    assert(Enum.count(geom.geometries) == 2)

    new_exjson = Geo.JSON.encode!(geom)
    assert(exjson == new_exjson)
  end

  test "GeoJSON to GeometryCollection" do
    json = """
      {
          "attribution": "BAN",
          "licence": "ODbL 1.0",
          "query": "8 bd du port",
          "type": "FeatureCollection",
          "version": "draft",
          "features": [
            {
              "properties": {
                "context": "80, Somme, Picardie",
                "housenumber": "8",
                "label": "8 Boulevard du Port 80000 Amiens",
                "postcode": "80000",
                "citycode": "80021",
                "id": "ADRNIVX_0000000260875032",
                "score": 0.3351181818181818,
                "name": "8 Boulevard du Port",
                "city": "Amiens",
                "type": "housenumber"
              },
              "geometry": {
                "type": "Point",
                "coordinates": [
                  2.29009,
                  49.897446
                ]
              },
              "type": "Feature"
            },
            {
              "properties": {
                "context": "34, Hérault, Languedoc-Roussillon",
                "housenumber": "8",
                "label": "8 Boulevard du Port 34140 Mèze",
                "postcode": "34140",
                "citycode": "34157",
                "id": "ADRNIVX_0000000284423783",
                "score": 0.3287575757575757,
                "name": "8 Boulevard du Port",
                "city": "Mèze",
                "type": "housenumber"
              },
              "geometry": {
                "type": "Point",
                "coordinates": [
                  3.605875,
                  43.425232
                ]
              },
              "type": "Feature"
            }
          ]
        }
    """

    geom = Jason.decode!(json) |> Geo.JSON.decode!()

    assert(Enum.count(geom.geometries) == 2)

    [geom1, _geom2] = geom.geometries
    assert geom1.coordinates == {2.29009, 49.897446}
    assert geom1.properties["label"] == "8 Boulevard du Port 80000 Amiens"
  end

  property "encodes and decodes back to the correct Point struct" do
    check all x <- float(),
              y <- float() do
      geom = %Geo.Point{coordinates: {x, y}}
      assert geom == Geo.JSON.encode!(geom) |> Geo.JSON.decode!()
    end
  end

  property "encodes and decodes back to the correct LineString struct" do
    check all list <- list_of({float(), float()}, min_length: 1) do
      geom = %Geo.LineString{coordinates: list}
      assert geom == Geo.JSON.encode!(geom) |> Geo.JSON.decode!()
    end
  end

  test "Point with properties to GeoJSON Feature map" do
    geom = %Geo.Point{coordinates: {100.0, 0.0}, properties: %{hi: "there"}}

    expected = %{
      "type" => "Feature",
      "properties" => %{
        "hi" => "there"
      },
      "geometry" => %{
        "type" => "Point",
        "coordinates" => [
          100.0,
          0.0
        ]
      }
    }

    assert(Geo.JSON.encode!(geom, feature: true) == expected)
  end

  test "Collection with properties to GeoJSON FeatureCollection map" do
    p1 = %Geo.Point{coordinates: {100.0, 0.0}, properties: %{hi: "there"}}
    p2 = %Geo.Point{coordinates: {0.0, 45.0}, properties: %{foo: 456.78}}
    gc = %Geo.GeometryCollection{geometries: [p1, p2], properties: %{hi: "other", foo: 123.45}}

    expected = %{
      "type" => "FeatureCollection",
      "features" => [
        %{
          "type" => "Feature",
          "properties" => %{
            "hi" => "there",
            "foo" => 123.45
          },
          "geometry" => %{
            "type" => "Point",
            "coordinates" => [
              100.0,
              0.0
            ]
          }
        },
        %{
          "type" => "Feature",
          "properties" => %{
            "hi" => "other",
            "foo" => 456.78
          },
          "geometry" => %{
            "type" => "Point",
            "coordinates" => [
              0.0,
              45.0
            ]
          }
        }
      ]
    }

    assert(Geo.JSON.encode!(gc, feature: true) == expected)
  end
end
