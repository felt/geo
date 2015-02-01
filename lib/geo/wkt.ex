defmodule Geo.WKT do
  alias Geo.Geometry
  @moduledoc """
  Converts to and from WKT and EWKT
  
      point = Geo.WKT.decode("POINT(30 -90)")
      Geo.Geometry[type: :point, coordinates: [30, -90], srid: nil]

      Geo.WKT.encode(point)
      "POINT(30 -90)"

      point = Geo.WKT.decode("SRID=4326;POINT(30 -90)")
      Geo.Geometry[type: :point, coordinates: [30, -90], srid: 4326]
  
  """

  @doc """
  Takes a Geo.Geometry or list of Geo.Geometry and returns a WKT string
  """
  def encode(geometry) when is_list(geometry) do
      geometries = Enum.map(geometry, fn(x) -> encode(%{ x | srid: nil }) end)
      srid = nil

      if(Enum.count(geometry) > 0) do
        srid = hd(geometry).srid
      end

      get_srid_binary(srid) <> "GEOMETRYCOLLECTION(#{Enum.join(geometries, ",")})"
  end

  def encode(%Geometry{ type: :point, coordinates: coordinates, srid: srid }) do
    get_srid_binary(srid) <> "POINT(#{Enum.join(coordinates, " ")})"
  end

  def encode(%Geometry{ type: :line_string, coordinates: coordinates, srid: srid }) do
    s = Enum.map(coordinates, fn(x) -> Enum.join(x, " ") end)
    get_srid_binary(srid) <> "LINESTRING(#{Enum.join(s, ", ")})"
  end

  def encode(%Geometry{ type: :polygon, coordinates: coordinates, srid: srid }) do
    s = Enum.map(coordinates, fn(x) -> Enum.join(Enum.map(x, fn(y) -> Enum.join(y," ") end), ", ") end)
    get_srid_binary(srid) <> "POLYGON((#{Enum.join(s, "),(")}))"
  end

  def encode(%Geometry{ type: :multi_point, coordinates: coordinates, srid: srid }) do
    s = Enum.map(coordinates, fn(x) -> Enum.join(x, " ") end)
    get_srid_binary(srid) <> "MULTIPOINT(#{Enum.join(s, ", ")})"
  end

  def encode(%Geometry{ type: :multi_line_string, coordinates: coordinates, srid: srid }) do
    s = Enum.map(coordinates, fn(x) -> Enum.join(Enum.map(x, fn(y) -> Enum.join(y," ") end), ", ") end)
    get_srid_binary(srid) <> "MULTILINESTRING((#{Enum.join(s, "),(")}))"
  end

  def encode(%Geometry{ type: :multi_polygon, coordinates: coordinates, srid: srid }) do
    s = Enum.map(coordinates,
      fn(c) -> Enum.join(Enum.map(c,
        fn(x) -> Enum.join(Enum.map(x,
          fn(y) -> Enum.join(y," ") end), ", ")
        end), "),(")
      end)
    get_srid_binary(srid) <> "MULTIPOLYGON(((#{Enum.join(s, ")),((")})))"
  end

  defp get_srid_binary(srid) do
    if srid, do: "SRID=#{srid};", else: ""
  end

  @doc """
  Takes a WKT string and returns a Geo.Geometry struct or list of Geo.Geometry
  """
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

  defp do_decode("GEOMETRYCOLLECTION" <> coordinates, srid) do
    String.slice(coordinates, 0..(String.length(coordinates)-2))
    |> String.split(",", [parts: 2])
    |> Enum.map(fn(x) ->
      case x do
        "(" <> wkt ->
          do_decode(wkt, srid)
        _ ->
          do_decode(x, srid)
      end
    end)
  end

  defp do_decode("POINT" <> coordinates, srid) do
    %Geometry{ type: :point, coordinates: create_point(coordinates), srid: srid }
  end

  defp do_decode("LINESTRING" <> coordinates, srid) do
    %Geometry{ type: :line_string, coordinates: create_line_string(coordinates), srid: srid }
  end

  defp do_decode("POLYGON" <> coordinates, srid) do
    coordinates = String.split(coordinates, "),(")
    |> Enum.map(fn(x) -> String.replace(x, ")", "") |> String.replace("(", "") end)

    %Geometry{ type: :polygon, coordinates: Enum.map(coordinates, &create_line_string(&1)), srid: srid }
  end

  defp do_decode("MULTIPOINT" <> coordinates, srid) do
    coordinates = String.replace(coordinates, ")","") |> String.replace("(","")
    %Geometry{ type: :multi_point, coordinates: create_line_string(coordinates), srid: srid }
  end

  defp do_decode("MULTILINESTRING" <> coordinates, srid) do
    coordinates = String.split(coordinates, "),(")
    |> Enum.map(fn(x) -> String.replace(x, ")", "") |> String.replace("(", "") end)

    %Geometry{ type: :multi_line_string, coordinates: Enum.map(coordinates, &create_line_string(&1)), srid: srid }
  end

  defp do_decode("MULTIPOLYGON" <> coordinates, srid) do


    coordinates = String.slice(coordinates,0..(String.length(coordinates)-2))
    |> String.split(")),((")
    |> Enum.map(fn(x) -> 
      do_decode("POLYGON(#{x})", srid).coordinates 
    end)

    %Geometry{ type: :multi_polygon, coordinates: coordinates, srid: srid }
  end

  defp create_point(coordinates) do
    coordinates
    |> String.strip
    |> String.replace("(", "")
    |> String.replace(")", "")
    |> String.split
    |> Enum.map(fn(x) -> binary_to_number(x) end)
  end

  defp create_line_string(coordinates) do
    coordinates
    |> String.strip
    |> String.replace("(", "")
    |> String.replace(")", "")
    |> String.split(",")
    |> Enum.map(&create_point(&1))
  end

  defp binary_to_number(binary) do
    if String.contains?(binary,"."), do: String.to_float(binary), else: String.to_integer(binary)
  end
end
