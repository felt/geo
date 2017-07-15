defmodule Geo do
  @moduledoc """
A collection of GIS functions. Handles conversions to and from WKT, WKB, and GeoJSON for the following geometries:

* Point
* LineString
* Polygon
* MultiPoint
* MulitLineString
* MultiPolygon
* GeometryCollection

## Examples


* Encode and decode WKT and EWKT

  ```elixir
  iex(1)> point = Geo.WKT.decode("POINT(30 -90)")
  %Geo.Point{ coordinates: {30, -90}, srid: nil}

  iex(2)> Geo.WKT.encode(point)
  "POINT(30 -90)"

  iex(3)> point = Geo.WKT.decode("SRID=4326;POINT(30 -90)")
  %Geo.Point{coordinates: {30, -90}, srid: 4326}
  ```


* Encode and decode WKB and EWKB

  ```elixir
  iex(1)> point = Geo.WKB.decode("0101000000000000000000F03F000000000000F03F")
  %Geo.Point{ coordinates: {1.0, 1.0}, srid: nil }

  iex(2)> Geo.WKB.encode(point)
  "00000000013FF00000000000003FF0000000000000"

  iex(3)> point = Geo.WKB.decode("0101000020E61000009EFB613A637B4240CF2C0950D3735EC0")
  %Geo.Point{ coordinates: {36.9639657, -121.8097725}, srid: 4326 }

  iex(4)> Geo.WKB.encode(point)
  "0020000001000010E640427B633A61FB9EC05E73D350092CCF"
  ```

* Encode and decode GeoJSON

  Geo only encodes and decodes maps shaped as GeoJSON. JSON encoding and decoding must
  be done before and after.

  ```elixir
  #Examples using Poison as the JSON parser

  iex(1)> Geo.JSON.encode(point)
  %{ "type" => "Point", "coordinates" => [100.0, 0.0] }

  iex(2)> point = Poison.decode!("{ \"type\": \"Point\", \"coordinates\": [100.0, 0.0] }") |> Geo.JSON.decode
  %Geo.Point{ coordinates: {100.0, 0.0}, srid: nil }

  iex(3)> Geo.JSON.encode(point) |> Poison.encode!
  "{\"type\":\"Point\",\"coordinates\":[100.0,0.0]}"
  ```
  """

  @type geometry :: Geo.Point.t | Geo.PointZ.t | Geo.PointM.t | Geo.PointZM.t |
  Geo.LineString.t | Geo.Polygon.t | Geo.MultiPoint.t | Geo.MultiLineString.t |
  Geo.MultiPolygon.t | Geo.GeometryCollection.t

  @type endian :: :ndr | :xdr

  defimpl String.Chars, for: Geo.Point do
    def to_string(geo) do
      Geo.WKT.encode(geo)
    end
  end

  defimpl String.Chars, for: Geo.PointZ do
    def to_string(geo) do
      Geo.WKT.encode(geo)
    end
  end

  defimpl String.Chars, for: Geo.PointM do
    def to_string(geo) do
      Geo.WKT.encode(geo)
    end
  end

  defimpl String.Chars, for: Geo.PointZM do
    def to_string(geo) do
      Geo.WKT.encode(geo)
    end
  end

  defimpl String.Chars, for: Geo.LineString do
    def to_string(geo) do
      Geo.WKT.encode(geo)
    end
  end

  defimpl String.Chars, for: Geo.Polygon do
    def to_string(geo) do
      Geo.WKT.encode(geo)
    end
  end

  defimpl String.Chars, for: Geo.MultiPoint do
    def to_string(geo) do
      Geo.WKT.encode(geo)
    end
  end

  defimpl String.Chars, for: Geo.MultiLineString do
    def to_string(geo) do
      Geo.WKT.encode(geo)
    end
  end

  defimpl String.Chars, for: Geo.MultiPolygon do
    def to_string(geo) do
      Geo.WKT.encode(geo)
    end
  end

  defimpl String.Chars, for: Geo.GeometryCollection do
    def to_string(geo) do
      Geo.WKT.encode(geo)
    end
  end

end
