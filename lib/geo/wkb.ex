defmodule Geo.WKB do
  alias Geo.Point
  alias Geo.LineString
  alias Geo.Polygon
  alias Geo.MultiPoint
  alias Geo.MultiLineString
  alias Geo.MultiPolygon
  alias Geo.GeometryCollection

  alias Geo.WKB.Reader
  alias Geo.WKB.Writer
  alias Geo.Utils
  use Bitwise

  @moduledoc """
  Converts to and from WKB and EWKB
  
      point = Geo.WKB.decode("0101000000000000000000F03F000000000000F03F")
      Geo.Point[coordinates: {1, 1}, srid: nil]

      Geo.WKT.encode(point)
      "POINT(1 1)"

      point = Geo.WKB.decode("0101000020E61000009EFB613A637B4240CF2C0950D3735EC0")
      Geo.Point[coordinates: {36.9639657, -121.8097725}, srid: 4326]
  """

  @doc """
  Takes a Geometry and returns a WKB string. The endian decides
  what the byte order will be
  """
  @spec encode(binary, Geo.endian) :: binary
  def encode(geom, endian \\ :xdr) do
    writer = Writer.start(endian)
    do_encode(geom, writer)
  end

  defp do_encode(%GeometryCollection{} = geom, writer) do
    type = Utils.type_to_hex(geom, geom.srid != nil)
            |> Integer.to_string(16)
            |> Utils.pad_left(8)

    srid = ""
    if geom.srid do
      srid = Integer.to_string(geom.srid, 16) |>Utils.pad_left(8)
    end

    count = Integer.to_string(Enum.count(geom.geometries), 16) |>Utils.pad_left(8)

    writer = Writer.write(writer, type)
    writer = Writer.write(writer, srid)
    writer = Writer.write(writer, count)

    coordinates = Enum.map(geom.geometries,
      fn(x) ->
        x = %{x | srid: nil}
        encode(x, Writer.get_endian(writer))
      end)

    coordinates = Enum.join(coordinates)

    Writer.get_wkb(writer) <> coordinates
  end

  defp do_encode(geom, writer) do
    type = Utils.type_to_hex(geom, geom.srid != nil)
            |> Integer.to_string(16)
            |> Utils.pad_left(8)

    srid = ""
    if geom.srid do
      srid = Integer.to_string(geom.srid, 16) |>Utils.pad_left(8)
    end

    writer = Writer.write(writer, type)
    writer = Writer.write(writer, srid)

    writer = encode_coordinates(writer, geom)
    Writer.get_wkb(writer)
  end

  defp encode_coordinates(writer, %Point{coordinates: {0, 0}}) do
      Writer.write(writer,Utils.repeat("0", 32))
  end

  defp encode_coordinates(writer, %Point{coordinates: {x, y}}) do
      x = x |> Utils.float_to_hex(64) |> Integer.to_string(16)
      y = y |> Utils.float_to_hex(64) |> Integer.to_string(16)

      writer = Writer.write(writer, x)
      Writer.write(writer, y)
  end

  defp encode_coordinates(writer, %LineString{coordinates: coordinates}) do
    number_of_points = Integer.to_string(length(coordinates), 16) |> Utils.pad_left(8)
    writer = Writer.write(writer, number_of_points)

    {_nils, writer} = Enum.map_reduce(coordinates, writer, fn(pair, acc) ->
      acc = encode_coordinates(acc, %Point{ coordinates: pair })
      {nil, acc}
    end)

    writer

  end

  defp encode_coordinates(writer, %Polygon{coordinates: coordinates}) do

    number_of_lines = Integer.to_string(length(coordinates), 16) |> Utils.pad_left(8)
    writer = Writer.write(writer, number_of_lines)

    {_nils, writer} = Enum.map_reduce(coordinates, writer, fn(line, acc) ->
      acc = encode_coordinates(acc, %LineString{ coordinates: line })
      {nil, acc}
    end)

    writer

  end

  defp encode_coordinates(writer, %MultiPoint{coordinates: coordinates}) do
    writer = Writer.write(writer, Integer.to_string(length(coordinates), 16) |> Utils.pad_left(8))

    geoms = Enum.map(coordinates, fn(geom) ->
      encode(%Point{ coordinates: geom }, Writer.get_endian(writer))
    end) |> Enum.join

    Writer.write_no_endian(writer, geoms)

  end

  defp encode_coordinates(writer, %MultiLineString{coordinates: coordinates}) do
    writer = Writer.write(writer, Integer.to_string(length(coordinates), 16) |> Utils.pad_left(8))

    geoms = Enum.map(coordinates, fn(geom) ->
      encode(%LineString{ coordinates: geom }, Writer.get_endian(writer))
    end) |> Enum.join

    Writer.write_no_endian(writer, geoms)
  end

  defp encode_coordinates(writer, %MultiPolygon{coordinates: coordinates}) do
    writer = Writer.write(writer, Integer.to_string(length(coordinates), 16) |> Utils.pad_left(8))

    geoms = Enum.map(coordinates, fn(geom) ->
      encode(%Polygon{ coordinates: geom }, Writer.get_endian(writer))
    end) |> Enum.join

    Writer.write_no_endian(writer, geoms)
  end

  @doc """
  Takes a WKB string and returns a Geometry
  """
  @spec decode(binary, [Geo.geometry]) :: Geo.geometry
  def decode(wkb, geometries \\ []) do
    wkb_reader = Reader.start(wkb)
    { type, wkb_reader } = Reader.read(wkb_reader, 8)

    srid = nil

    type = String.to_integer(type, 16)

    if (type &&& 0x20000000) != 0 do
      { srid, wkb_reader } = Reader.read(wkb_reader, 8)
      srid = String.to_integer(srid, 16)
    end

    type = Utils.hex_to_type(type &&& 0xff)

    {coordinates, wkb_reader} = decode_coordinates(type, wkb_reader)

    case type do
      %Geo.GeometryCollection{} ->
        coordinates = Enum.map(coordinates, fn(x) -> %{ x | srid: srid } end)
        geometries = %{ type | geometries: coordinates, srid: srid  }
      _ ->
        geometries = geometries ++ [ %{ type | coordinates: coordinates, srid: srid  }]         
    end  

    if(Reader.eof?(wkb_reader)) do
      return_geom(geometries)
    else
      Reader.get_wkb(wkb_reader) |> decode(geometries)
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
    { {x,y}, wkb_reader }
  end

  defp decode_coordinates(%LineString{}, wkb_reader) do
    {number_of_points, wkb_reader} = Reader.read(wkb_reader, 8)
    number_of_points = number_of_points |> String.to_integer(16)

    Enum.map_reduce(Enum.to_list(0..(number_of_points-1)), wkb_reader, fn(_x, acc) ->
      decode_coordinates(%Point{}, acc)
    end)
  end

  defp decode_coordinates(%Polygon{}, wkb_reader) do
    {number_of_lines, wkb_reader} = Reader.read(wkb_reader, 8)

    number_of_lines = number_of_lines |> String.to_integer(16)

    Enum.map_reduce(Enum.to_list(0..(number_of_lines-1)), wkb_reader, fn(_x, acc) ->
      decode_coordinates(%LineString{}, acc)
    end)
  end

  defp decode_coordinates(%GeometryCollection{}, wkb_reader) do
    {_number_of_items, wkb_reader} = Reader.read(wkb_reader, 8)
    { decode(Reader.get_wkb(wkb_reader)), Reader.start("00") }
  end

  defp decode_coordinates(_geom, wkb_reader) do
    {_number_of_items, wkb_reader} = Reader.read(wkb_reader, 8)

    geom_collection = Reader.get_wkb(wkb_reader) |> decode

    coordinates = Enum.map(geom_collection, fn(x) ->
      x.coordinates
    end)

    { coordinates, Reader.start("00") }
  end


end
