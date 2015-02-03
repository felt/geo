defmodule Geo.WKT do
  alias Geo.Point
  alias Geo.LineString
  alias Geo.Polygon
  alias Geo.MultiPoint
  alias Geo.MultiLineString
  alias Geo.MultiPolygon
  alias Geo.GeometryCollection

  @moduledoc """
  Converts to and from WKT and EWKT
  
      point = Geo.WKT.decode("POINT(30 -90)")
      Geo.Point[coordinates: {30, -90}, srid: nil]

      Geo.WKT.encode(point)
      "POINT(30 -90)"

      point = Geo.WKT.decode("SRID=4326;POINT(30 -90)")
      Geo.Point[coordinates: {30, -90}, srid: 4326]
  
  """

  @doc """
  Takes a Geometry and returns a WKT string
  """
  @spec encode(Geo.geometry) :: binary
  def encode(geom) do
    get_srid_binary(geom.srid) <> do_encode(geom)
  end

  defp do_encode(%Point{ coordinates: {x, y}}) do
    "POINT(#{x} #{y})"
  end

  defp do_encode(%LineString{ coordinates: coordinates}) do
    coordinate_string = create_line_string_str(coordinates)

    "LINESTRING#{coordinate_string}"
  end

  defp do_encode(%Polygon{ coordinates: coordinates}) do
    coordinate_string = create_polygon_str(coordinates)

    "POLYGON#{coordinate_string}"
  end

  defp do_encode(%MultiPoint{ coordinates: coordinates}) do
    coordinate_string = create_line_string_str(coordinates)

    "MULTIPOINT#{coordinate_string}"
  end

  defp do_encode(%MultiLineString{ coordinates: coordinates}) do
    coordinate_string = create_polygon_str(coordinates)

    "MULTILINESTRING#{coordinate_string}"
  end

  defp do_encode(%MultiPolygon{ coordinates: coordinates}) do
    coordinate_string = create_multi_polygon_str(coordinates)

    "MULTIPOLYGON#{coordinate_string}"
  end

  defp do_encode(%GeometryCollection{ geometries: geometries}) do
    geom_str = Enum.map(geometries, &do_encode(&1)) |> Enum.join(",")

    "GEOMETRYCOLLECTION(#{geom_str})"
  end

  @doc """
  Takes a WKT string and returns a Geo.Geometry struct or list of Geo.Geometry
  """
  @spec decode(binary) :: Geo.geometry
  def decode(wkt) do
      wkt_split = String.split(wkt, ";")
      srid = nil
      actual_wkt = wkt
      if length(wkt_split) == 2 do
        srid = hd(wkt_split) |> String.replace("SRID=","") |> String.to_integer
        actual_wkt = List.last(wkt_split)
      end

      do_decode(actual_wkt, srid)
  end

  defp do_decode("POINT" <> coordinates, srid) do
    %Point{ coordinates: create_point(coordinates), srid: srid }
  end

  defp do_decode("LINESTRING" <> coordinates, srid) do
    %LineString{ coordinates: create_line_string(coordinates), srid: srid }
  end

  defp do_decode("POLYGON" <> coordinates, srid) do
    %Polygon{ coordinates: create_polygon(coordinates), srid: srid }
  end

  defp do_decode("MULTIPOINT" <> coordinates, srid) do
    %MultiPoint{ coordinates: create_line_string(coordinates), srid: srid }
  end

  defp do_decode("MULTILINESTRING" <> coordinates, srid) do
    %MultiLineString{ coordinates: create_polygon(coordinates), srid: srid }
  end

  defp do_decode("MULTIPOLYGON" <> coordinates, srid) do
    %MultiPolygon{ coordinates: create_multi_polygon(coordinates), srid: srid }
  end

  defp do_decode("GEOMETRYCOLLECTION" <> coordinates, srid) do

    geometries = String.slice(coordinates, 0..(String.length(coordinates)-2))
    |> String.split(",", [parts: 2])
    |> Enum.map(fn(x) ->
      case x do
        "(" <> wkt ->
          do_decode(wkt, srid)
        _ ->
          do_decode(x, srid)
      end
    end)

    %GeometryCollection{ geometries: geometries, srid: srid }
  end

  defp create_point(coordinates) do

    coordinates
    |> String.strip
    |> remove_outer_parenthesis
    |> String.split
    |> Enum.map(fn(x) -> binary_to_number(x) end)
    |> List.to_tuple
  end

  defp create_line_string(coordinates) do
    coordinates
    |> String.strip
    |> remove_outer_parenthesis
    |> String.split(",")
    |> Enum.map(&create_point(&1))
  end

  defp create_polygon(coordinates) do
    coordinates
    |> String.strip
    |> remove_outer_parenthesis
    |> String.split("),(")
    |> Enum.map(&repair_str(&1, "(", ")"))
    |> Enum.map(&create_line_string(&1))
  end

  defp create_multi_polygon(coordinates) do
    coordinates
    |> String.strip
    |> remove_outer_parenthesis
    |> String.split(")),((")
    |> Enum.map(&repair_str(&1, "((", "))"))
    |> Enum.map(&create_polygon(&1))
  end

  defp binary_to_number(binary) do
    if String.contains?(binary,"."), do: String.to_float(binary), else: String.to_integer(binary)
  end

  defp remove_outer_parenthesis(coordinates) do
    coordinates
    |> String.replace("(", "", global: false)
    |> String.reverse
    |> String.replace(")", "", global: false)
    |> String.reverse
  end


  defp create_pair_str({x, y}) do
    "#{x} #{y}"
  end

  defp create_line_string_str(coordinates) do
    coordinate_str = coordinates
    |> Enum.map(&create_pair_str(&1))
    |> Enum.join(",")

    "(#{coordinate_str})"
  end

  defp create_polygon_str(coordinates) do
    coordinate_str = coordinates
    |> Enum.map(&create_line_string_str(&1))
    |> Enum.join(",")

    "(#{coordinate_str})"
  end

  defp create_multi_polygon_str(coordinates) do
    coordinate_str = coordinates
    |> Enum.map(&create_polygon_str(&1))
    |> Enum.join(",")

    "(#{coordinate_str})"
  end

  defp get_srid_binary(srid) do
    if srid, do: "SRID=#{srid};", else: ""
  end

  defp repair_str(str, starts, ends) do
      if !String.starts_with?(str, starts) do
        str = starts <> str
      end

      if !String.ends_with?(str, ends) do
        str = str <> ends
      end

      str
  end
end
