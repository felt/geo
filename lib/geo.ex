defmodule Geo do
  @moduledoc """
  A collection of GIS functions. Handles conversions to and from WKT, WKB, and GeoJSON for the following geometries:

  * Point
  * PointZ
  * LineString
  * LineStringZ
  * Polygon
  * PolygonZ
  * MultiPoint
  * MultiPointZ
  * MulitLineString
  * MulitLineStringZ
  * MultiPolygon
  * MultiPolygonZ
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
    #Examples using Jason as the JSON parser

    iex(1)> Geo.JSON.encode(point)
    %{ "type" => "Point", "coordinates" => [100.0, 0.0] }

    iex(2)> point = Jason.decode!("{ \"type\": \"Point\", \"coordinates\": [100.0, 0.0] }") |> Geo.JSON.decode
    %Geo.Point{ coordinates: {100.0, 0.0}, srid: nil }

    iex(3)> Geo.JSON.encode(point) |> Jason.encode!
    "{\"type\":\"Point\",\"coordinates\":[100.0,0.0]}"
    ```
  """

  @type geometry ::
          Geo.Point.t()
          | Geo.PointZ.t()
          | Geo.PointM.t()
          | Geo.PointZM.t()
          | Geo.LineString.t()
          | Geo.LineStringZ.t()
          | Geo.Polygon.t()
          | Geo.PolygonZ.t()
          | Geo.MultiPoint.t()
          | Geo.MultiPointZ.t()
          | Geo.MultiLineString.t()
          | Geo.MultiLineStringZ.t()
          | Geo.MultiPolygon.t()
          | Geo.MultiPolygonZ.t()
          | Geo.GeometryCollection.t()

  @typedoc """
  Endianess (byte-order) of the WKB/EWKB representation.

    * `:ndr` - little-endian
    * `:xdr` - big-endian

  """
  @type endian :: :ndr | :xdr

  if Application.get_env(:geo, :impl_to_string, true) do
    defimpl String.Chars,
      for: [
        Geo.Point,
        Geo.PointZ,
        Geo.PointM,
        Geo.PointZM,
        Geo.LineString,
        Geo.LineStringZ,
        Geo.Polygon,
        Geo.PolygonZ,
        Geo.MultiPoint,
        Geo.MultiPointZ,
        Geo.MultiLineString,
        Geo.MultiLineStringZ,
        Geo.MultiPolygon,
        Geo.MultiPolygonZ,
        Geo.GeometryCollection
      ] do
      def to_string(geo) do
        Geo.WKT.encode!(geo)
      end
    end
  end

  if Code.ensure_loaded?(Jason.Encoder) do
    defimpl Jason.Encoder,
      for: [
        Geo.Point,
        Geo.PointZ,
        Geo.PointM,
        Geo.PointZM,
        Geo.LineString,
        Geo.LineStringZ,
        Geo.Polygon,
        Geo.PolygonZ,
        Geo.MultiPoint,
        Geo.MultiPointZ,
        Geo.MultiLineString,
        Geo.MultiLineStringZ,
        Geo.MultiPolygon,
        Geo.MultiPolygonZ,
        Geo.GeometryCollection
      ] do
      def encode(value, opts) do
        Jason.Encode.map(Geo.JSON.encode!(value), opts)
      end
    end
  end
end
