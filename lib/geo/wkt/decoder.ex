defmodule Geo.WKT.Decoder do
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
    MultiPolygon,
    MultiPolygonZ,
    GeometryCollection
  }

  @doc """
  Takes a WKT string and returns a Geo.geometry struct or list of Geo.geometry.
  """
  @spec decode(binary) :: {:ok, Geo.geometry()} | {:error, Exception.t()}
  def decode(wkb) do
    {:ok, decode!(wkb)}
  rescue
    exception ->
      {:error, exception}
  end

  @doc """
  Takes a WKT string and returns a Geo.geometry struct or list of Geo.geometry.
  """
  @spec decode!(binary) :: Geo.geometry()
  def decode!(wkt) do
    wkt_split = String.split(wkt, ";")

    {srid, actual_wkt} =
      if length(wkt_split) == 2 do
        {hd(wkt_split) |> String.replace("SRID=", "") |> String.to_integer(),
         List.last(wkt_split)}
      else
        {nil, wkt}
      end

    do_decode(actual_wkt, srid)
  end

  defp do_decode("POINT ZM" <> coordinates, srid) do
    %PointZM{coordinates: create_point(coordinates), srid: srid}
  end

  defp do_decode("POINT Z" <> coordinates, srid) do
    %PointZ{coordinates: create_point(coordinates), srid: srid}
  end

  defp do_decode("POINT M" <> coordinates, srid) do
    %PointM{coordinates: create_point(coordinates), srid: srid}
  end

  defp do_decode("POINT" <> coordinates, srid) do
    %Point{coordinates: create_point(coordinates), srid: srid}
  end

  defp do_decode("LINESTRINGM" <> coordinates, srid) do
    %LineStringM{coordinates: create_line_string(coordinates), srid: srid}
  end

  defp do_decode("LINESTRINGZ" <> coordinates, srid) do
    %LineStringZ{coordinates: create_line_string(coordinates), srid: srid}
  end

  defp do_decode("LINESTRING" <> coordinates, srid) do
    %LineString{coordinates: create_line_string(coordinates), srid: srid}
  end

  defp do_decode("POLYGONZ" <> coordinates, srid) do
    %PolygonZ{coordinates: create_polygon(coordinates), srid: srid}
  end

  defp do_decode("POLYGON" <> coordinates, srid) do
    %Polygon{coordinates: create_polygon(coordinates), srid: srid}
  end

  defp do_decode("MULTIPOINTM" <> coordinates, srid) do
    %MultiPointM{coordinates: create_line_string(coordinates), srid: srid}
  end

  defp do_decode("MULTIPOINTZ" <> coordinates, srid) do
    %MultiPointZ{coordinates: create_line_string(coordinates), srid: srid}
  end

  defp do_decode("MULTILINESTRING" <> coordinates, srid) do
    %MultiLineString{coordinates: create_polygon(coordinates), srid: srid}
  end

  defp do_decode("MULTIPOINT" <> coordinates, srid) do
    %MultiPoint{coordinates: create_line_string(coordinates), srid: srid}
  end

  defp do_decode("MULTIPOLYGONZ" <> coordinates, srid) do
    %MultiPolygonZ{coordinates: create_multi_polygon(coordinates), srid: srid}
  end

  defp do_decode("MULTIPOLYGON" <> coordinates, srid) do
    %MultiPolygon{coordinates: create_multi_polygon(coordinates), srid: srid}
  end

  defp do_decode("GEOMETRYCOLLECTION" <> coordinates, srid) do
    geometries =
      String.slice(coordinates, 0..(String.length(coordinates) - 2))
      |> String.split(",", parts: 2)
      |> Enum.map(fn x ->
        case x do
          "(" <> wkt ->
            do_decode(wkt, srid)

          _ ->
            do_decode(x, srid)
        end
      end)

    %GeometryCollection{geometries: geometries, srid: srid}
  end

  defp create_point(coordinates) do
    coordinates
    |> String.trim()
    |> remove_outer_parenthesis
    |> String.split()
    |> Enum.map(fn x -> binary_to_number(x) end)
    |> List.to_tuple()
  end

  defp create_line_string(coordinates) do
    coordinates
    |> String.trim()
    |> remove_outer_parenthesis
    |> String.split(",")
    |> Enum.map(&create_point(&1))
  end

  defp create_polygon(coordinates) do
    coordinates
    |> String.trim()
    |> remove_outer_parenthesis
    |> String.split(~r{\), *\(})
    |> Enum.map(&repair_str(&1, "(", ")"))
    |> Enum.map(&create_line_string(&1))
  end

  defp create_multi_polygon(coordinates) do
    coordinates
    |> String.trim()
    |> remove_outer_parenthesis
    |> String.split(~r{\)\), *\(\(})
    |> Enum.map(&repair_str(&1, "((", "))"))
    |> Enum.map(&create_polygon(&1))
  end

  defp binary_to_number(binary) do
    if String.contains?(binary, "."), do: String.to_float(binary), else: String.to_integer(binary)
  end

  defp remove_outer_parenthesis(coordinates) do
    coordinates
    |> String.replace("(", "", global: false)
    |> String.reverse()
    |> String.replace(")", "", global: false)
    |> String.reverse()
  end

  def repair_str(str, starts, ends) do
    str = if !String.starts_with?(str, starts), do: starts <> str, else: str
    str = if !String.ends_with?(str, ends), do: str <> ends, else: str

    str
  end
end
