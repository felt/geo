defmodule Geo do
  @moduledoc """
  A collection of GIS functions.
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
