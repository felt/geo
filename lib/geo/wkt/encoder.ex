defmodule Geo.WKT.Encoder do
  @moduledoc false

  alias Geo.{
    Point,
    PointZ,
    PointM,
    PointZM,
    LineString,
    LineStringM,
    LineStringZ,
    Polygon,
    PolygonZ,
    MultiPoint,
    MultiPointM,
    MultiPointZ,
    MultiLineString,
    MultiLineStringZ,
    MultiPolygon,
    MultiPolygonZ,
    GeometryCollection
  }

  @doc """
  Takes a Geometry and returns a WKT string.
  """
  @spec encode(Geo.geometry()) :: {:ok, binary} | {:error, Exception.t()}
  def encode(geom) do
    {:ok, encode!(geom)}
  rescue
    exception ->
      {:error, exception}
  end

  @doc """
  Takes a Geometry and returns a WKT string.
  """
  @spec encode!(Geo.geometry()) :: binary
  def encode!(geom) do
    get_srid_binary(geom.srid) <> do_encode(geom)
  end

  defp do_encode(%Point{coordinates: {x, y}}) do
    "POINT(#{x} #{y})"
  end

  defp do_encode(%PointZ{coordinates: {x, y, z}}) do
    "POINT Z(#{x} #{y} #{z})"
  end

  defp do_encode(%PointM{coordinates: {x, y, m}}) do
    "POINT M(#{x} #{y} #{m})"
  end

  defp do_encode(%PointZM{coordinates: {x, y, z, m}}) do
    "POINT ZM(#{x} #{y} #{z} #{m})"
  end

  defp do_encode(%LineString{coordinates: coordinates}) do
    coordinate_string = create_line_string_str(coordinates)

    "LINESTRING#{coordinate_string}"
  end

  defp do_encode(%LineStringM{coordinates: coordinates}) do
    coordinate_string = create_line_string_str(coordinates)

    "LINESTRINGM#{coordinate_string}"
  end

  defp do_encode(%LineStringZ{coordinates: coordinates}) do
    coordinate_string = create_line_string_str(coordinates)

    "LINESTRINGZ#{coordinate_string}"
  end

  defp do_encode(%Polygon{coordinates: coordinates}) do
    coordinate_string = create_polygon_str(coordinates)

    "POLYGON#{coordinate_string}"
  end

  defp do_encode(%PolygonZ{coordinates: coordinates}) do
    coordinate_string = create_polygon_str(coordinates)

    "POLYGON#{coordinate_string}"
  end

  defp do_encode(%MultiPoint{coordinates: coordinates}) do
    coordinate_string = create_line_string_str(coordinates)

    "MULTIPOINT#{coordinate_string}"
  end

  defp do_encode(%MultiPointM{coordinates: coordinates}) do
    coordinate_string = create_line_string_str(coordinates)

    "MULTIPOINTM#{coordinate_string}"
  end

  defp do_encode(%MultiPointZ{coordinates: coordinates}) do
    coordinate_string = create_line_string_str(coordinates)

    "MULTIPOINTZ#{coordinate_string}"
  end

  defp do_encode(%MultiLineString{coordinates: coordinates}) do
    coordinate_string = create_polygon_str(coordinates)

    "MULTILINESTRING#{coordinate_string}"
  end

  defp do_encode(%MultiLineStringZ{coordinates: coordinates}) do
    coordinate_string = create_polygon_str(coordinates)

    "MULTILINESTRINGZ#{coordinate_string}"
  end

  defp do_encode(%MultiPolygon{coordinates: coordinates}) do
    coordinate_string = create_multi_polygon_str(coordinates)

    "MULTIPOLYGON#{coordinate_string}"
  end

  defp do_encode(%MultiPolygonZ{coordinates: coordinates}) do
    coordinate_string = create_multi_polygon_str(coordinates)

    "MULTIPOLYGONZ#{coordinate_string}"
  end

  defp do_encode(%GeometryCollection{geometries: geometries}) do
    geom_str = Enum.map(geometries, &do_encode(&1)) |> Enum.join(",")

    "GEOMETRYCOLLECTION(#{geom_str})"
  end

  defp create_line_string_str(coordinates) do
    coordinate_str =
      coordinates
      |> Enum.map(&create_coord_str(&1))
      |> Enum.join(",")

    "(#{coordinate_str})"
  end

  defp create_polygon_str(coordinates) do
    coordinate_str =
      coordinates
      |> Enum.map(&create_line_string_str(&1))
      |> Enum.join(",")

    "(#{coordinate_str})"
  end

  defp create_multi_polygon_str(coordinates) do
    coordinate_str =
      coordinates
      |> Enum.map(&create_polygon_str(&1))
      |> Enum.join(",")

    "(#{coordinate_str})"
  end

  defp create_coord_str({x, y}), do: "#{x} #{y}"
  defp create_coord_str({x, y, z}), do: "#{x} #{y} #{z}"

  defp get_srid_binary(nil), do: ""
  defp get_srid_binary(0), do: ""
  defp get_srid_binary(srid), do: "SRID=#{srid};"
end
