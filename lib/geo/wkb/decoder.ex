defmodule Geo.WKB.Decoder do
  @moduledoc false

  use Bitwise

  alias Geo.{
    Point,
    PointZ,
    PointM,
    PointZM,
    LineString,
    LineStringZ,
    Polygon,
    PolygonZ,
    GeometryCollection,
    Utils
  }

  alias Geo.WKB.Reader

  @doc """
  Takes a WKB string and returns a Geometry.
  """
  @spec decode(binary, [Geo.geometry()]) :: {:ok, Geo.geometry()} | {:error, Exception.t()}
  def decode(wkb, geometries \\ []) do
    {:ok, decode!(wkb, geometries)}
  rescue
    exception ->
      {:error, exception}
  end

  @doc """
  Takes a WKB string and returns a Geometry.
  """
  @spec decode!(binary, [Geo.geometry()]) :: Geo.geometry() | no_return
  def decode!(wkb, geometries \\ []) do
    wkb_reader = Reader.new(wkb)
    {type, wkb_reader} = Reader.read(wkb_reader, 8)

    type = String.to_integer(type, 16)

    {srid, wkb_reader} =
      if (type &&& 0x20000000) != 0 do
        {srid, wkb_reader} = Reader.read(wkb_reader, 8)
        {String.to_integer(srid, 16), wkb_reader}
      else
        {nil, wkb_reader}
      end

    type = Utils.hex_to_type(type &&& 0xDF_FF_FF_FF)

    {coordinates, wkb_reader} = decode_coordinates(type, wkb_reader)

    geometries =
      case type do
        %Geo.GeometryCollection{} ->
          coordinates =
            coordinates
            |> Enum.map(fn x -> %{x | srid: srid} end)

          %{type | geometries: coordinates, srid: srid}

        _ ->
          geometries ++ [%{type | coordinates: coordinates, srid: srid}]
      end

    if Reader.eof?(wkb_reader) do
      return_geom(geometries)
    else
      wkb_reader.wkb |> decode!(geometries)
    end
  end

  defp return_geom(%GeometryCollection{} = geom) do
    geom
  end

  defp return_geom(geom) when is_list(geom) do
    if length(geom) == 1 do
      hd(geom)
    else
      geom
    end
  end

  defp decode_coordinates(%Point{}, wkb_reader) do
    {x, wkb_reader} = Reader.read(wkb_reader, 16)
    x = Utils.hex_to_float(x)

    {y, wkb_reader} = Reader.read(wkb_reader, 16)
    y = Utils.hex_to_float(y)
    {{x, y}, wkb_reader}
  end

  defp decode_coordinates(%PointZ{}, wkb_reader) do
    {x, wkb_reader} = Reader.read(wkb_reader, 16)
    x = Utils.hex_to_float(x)

    {y, wkb_reader} = Reader.read(wkb_reader, 16)
    y = Utils.hex_to_float(y)

    {z, wkb_reader} = Reader.read(wkb_reader, 16)
    z = Utils.hex_to_float(z)
    {{x, y, z}, wkb_reader}
  end

  defp decode_coordinates(%PointM{}, wkb_reader) do
    {x, wkb_reader} = Reader.read(wkb_reader, 16)
    x = Utils.hex_to_float(x)

    {y, wkb_reader} = Reader.read(wkb_reader, 16)
    y = Utils.hex_to_float(y)

    {m, wkb_reader} = Reader.read(wkb_reader, 16)
    m = Utils.hex_to_float(m)
    {{x, y, m}, wkb_reader}
  end

  defp decode_coordinates(%PointZM{}, wkb_reader) do
    {x, wkb_reader} = Reader.read(wkb_reader, 16)
    x = Utils.hex_to_float(x)

    {y, wkb_reader} = Reader.read(wkb_reader, 16)
    y = Utils.hex_to_float(y)

    {z, wkb_reader} = Reader.read(wkb_reader, 16)
    z = Utils.hex_to_float(z)

    {m, wkb_reader} = Reader.read(wkb_reader, 16)
    m = Utils.hex_to_float(m)
    {{x, y, z, m}, wkb_reader}
  end

  defp decode_coordinates(%LineString{}, wkb_reader) do
    {number_of_points, wkb_reader} = Reader.read(wkb_reader, 8)
    number_of_points = number_of_points |> String.to_integer(16)

    Enum.map_reduce(Enum.to_list(0..(number_of_points - 1)), wkb_reader, fn _x, acc ->
      decode_coordinates(%Point{}, acc)
    end)
  end

  defp decode_coordinates(%LineStringZ{}, wkb_reader) do
    {number_of_points, wkb_reader} = Reader.read(wkb_reader, 8)
    number_of_points = number_of_points |> String.to_integer(16)

    Enum.map_reduce(Enum.to_list(0..(number_of_points - 1)), wkb_reader, fn _x, acc ->
      decode_coordinates(%PointZ{}, acc)
    end)
  end

  defp decode_coordinates(%Polygon{}, wkb_reader) do
    {number_of_lines, wkb_reader} = Reader.read(wkb_reader, 8)

    number_of_lines = number_of_lines |> String.to_integer(16)

    Enum.map_reduce(Enum.to_list(0..(number_of_lines - 1)), wkb_reader, fn _x, acc ->
      decode_coordinates(%LineString{}, acc)
    end)
  end

  defp decode_coordinates(%PolygonZ{}, wkb_reader) do
    {number_of_lines, wkb_reader} = Reader.read(wkb_reader, 8)

    number_of_lines = number_of_lines |> String.to_integer(16)

    Enum.map_reduce(Enum.to_list(0..(number_of_lines - 1)), wkb_reader, fn _x, acc ->
      decode_coordinates(%LineStringZ{}, acc)
    end)
  end

  defp decode_coordinates(%GeometryCollection{}, wkb_reader) do
    {_number_of_items, wkb_reader} = Reader.read(wkb_reader, 8)
    geometries = decode!(wkb_reader.wkb)
    {List.wrap(geometries), Reader.new("00")}
  end

  defp decode_coordinates(_geom, wkb_reader) do
    {_number_of_items, wkb_reader} = Reader.read(wkb_reader, 8)

    decoded_geom =
      case wkb_reader.wkb do
        "" -> []
        wkb -> decode!(wkb)
      end

    coordinates =
      if is_list(decoded_geom) do
        Enum.map(decoded_geom, fn x ->
          x.coordinates
        end)
      else
        [decoded_geom.coordinates]
      end

    {coordinates, Reader.new("00")}
  end
end
