defmodule Geo.JSON.Test do
  use ExUnit.Case, async: true

  test "GeoJson to Point and back" do
  	json = "{ \"type\": \"Point\", \"coordinates\": [100.0, 0.0] }"
  	exjson = JSEX.decode!(json)
    geom = Geo.JSON.decode(json)
    assert(geom.type == :point)
    assert(geom.coordinates == [100.0, 0.0])
    new_exjson = JSEX.decode!(Geo.JSON.encode(geom))
    assert(exjson == new_exjson)
  end

  test "GeoJson to LineString and back" do
  	json = "{ \"type\": \"LineString\", \"coordinates\": [ [100.0, 0.0], [101.0, 1.0] ]}"
  	exjson = JSEX.decode!(json)
    geom = Geo.JSON.decode(json)
    assert(geom.type == :line_string)
    assert(geom.coordinates == [ [100.0, 0.0], [101.0, 1.0] ])
    new_exjson = JSEX.decode!(Geo.JSON.encode(geom))
    assert(exjson == new_exjson)
  end

  test "GeoJson to Polygon and back" do
  	json = "{ \"type\": \"Polygon\", \"coordinates\": [[ [100.0, 0.0], [101.0, 0.0], [101.0, 1.0], [100.0, 1.0], [100.0, 0.0] ]]}"
  	exjson = JSEX.decode!(json)
    geom = Geo.JSON.decode(json)
    assert(geom.type == :polygon)
    assert(geom.coordinates == [[ [100.0, 0.0], [101.0, 0.0], [101.0, 1.0], [100.0, 1.0], [100.0, 0.0] ]])
    new_exjson = JSEX.decode!(Geo.JSON.encode(geom))
    assert(exjson == new_exjson)
  end

  test "GeoJson to MultiPoint and back" do
  	json = "{ \"type\": \"MultiPoint\", \"coordinates\": [ [100.0, 0.0], [101.0, 1.0] ]}"
  	exjson = JSEX.decode!(json)
    geom = Geo.JSON.decode(json)
    assert(geom.type == :multi_point)
    assert(geom.coordinates == [ [100.0, 0.0], [101.0, 1.0] ])
    new_exjson = JSEX.decode!(Geo.JSON.encode(geom))
    assert(exjson == new_exjson)
  end

  test "GeoJson to MultiLineString and back" do
  	json = "{ \"type\": \"MultiLineString\", \"coordinates\": [[ [100.0, 0.0], [101.0, 1.0] ],[ [102.0, 2.0], [103.0, 3.0] ]]}"
  	exjson = JSEX.decode!(json)
    geom = Geo.JSON.decode(json)
    assert(geom.type == :multi_line_string)
    assert(geom.coordinates == [[ [100.0, 0.0], [101.0, 1.0] ],[ [102.0, 2.0], [103.0, 3.0] ]])
    new_exjson = JSEX.decode!(Geo.JSON.encode(geom))
    assert(exjson == new_exjson)
  end

  test "GeoJson to MultiPolygon and back" do
  	json = "{ \"type\": \"MultiPolygon\", \"coordinates\": [[[[102.0, 2.0], [103.0, 2.0], [103.0, 3.0], [102.0, 3.0], [102.0, 2.0]]],[[[100.0, 0.0], [101.0, 0.0], [101.0, 1.0], [100.0, 1.0], [100.0, 0.0]],[[100.2, 0.2], [100.8, 0.2], [100.8, 0.8], [100.2, 0.8], [100.2, 0.2]]]]}"
  	exjson = JSEX.decode!(json)
    geom = Geo.JSON.decode(json)
    assert(geom.type == :multi_polygon)
    assert(geom.coordinates == [[[[102.0, 2.0], [103.0, 2.0], [103.0, 3.0], [102.0, 3.0], [102.0, 2.0]]], [[[100.0, 0.0], [101.0, 0.0], [101.0, 1.0], [100.0, 1.0], [100.0, 0.0]],[[100.2, 0.2], [100.8, 0.2], [100.8, 0.8], [100.2, 0.8], [100.2, 0.2]]]])
    new_exjson = JSEX.decode!(Geo.JSON.encode(geom))
    assert(exjson == new_exjson)
  end

  test "GeoJson to GeometryCollection and back" do
  	json = "{ \"type\": \"GeometryCollection\",\"geometries\": [{ \"type\": \"Point\", \"coordinates\": [100.0, 0.0]},{ \"type\": \"LineString\",\"coordinates\": [ [101.0, 0.0], [102.0, 1.0] ]}]}"
  	exjson = JSEX.decode!(json)
    collection = Geo.JSON.decode(json)
    assert(Enum.count(collection) == 2)
    assert(hd(collection).type == :point)
    new_exjson = JSEX.decode!(Geo.JSON.encode(collection))
    assert(exjson == new_exjson)
  end

end
