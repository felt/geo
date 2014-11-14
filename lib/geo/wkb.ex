defmodule Geo.WKB do
  alias Geo.Geometry
  alias Geo.WKB.Reader
  alias Geo.WKB.Writer
  use Bitwise

  @hex_type_map %{point: 0x01, line_string: 0x02, polygon: 0x03, 
                  multi_point: 0x04, multi_line_string: 0x05, 
                  multi_polygon: 0x06, geometry_collection: 0x07}

  def encode(geom, endian \\ :xdr) do
    writer = Writer.start(endian)
    do_encode(geom, writer)
  end

  def do_encode(geom, writer) when is_list(geom) do
    type =  type_to_hex(:geometry_collection, hd(geom).srid != nil)
            |> Integer.to_string(16)
            |> Geo.Utils.pad_left(8)

    srid = ""
    if hd(geom).srid do
      srid = Integer.to_string(hd(geom).srid, 16) |> Geo.Utils.pad_left(8)
    end

    count = Integer.to_string(Enum.count(geom), 16) |> Geo.Utils.pad_left(8)

    writer = Writer.write(writer, type)
    writer = Writer.write(writer, srid)
    writer = Writer.write(writer, count)

    coordinates = Enum.map(geom,
      fn(x) ->
        encode(%Geometry{ type: x.type, coordinates: x.coordinates }, Writer.get_endian(writer))
      end)

    coordinates = Enum.join(coordinates, "")

    Writer.get_wkb(writer) <> coordinates
  end

  def do_encode(geom, writer) do
    type =  type_to_hex(geom.type, geom.srid != nil)
            |> Integer.to_string(16)
            |> Geo.Utils.pad_left(8)

    srid = ""
    if geom.srid do
      srid = Integer.to_string(geom.srid, 16) |> Geo.Utils.pad_left(8)
    end

    writer = Writer.write(writer, type)
    writer = Writer.write(writer, srid)

    writer = encode_coordinates(geom.type, geom.coordinates, writer)
    Writer.get_wkb(writer)
  end

  defp encode_coordinates(:point, coordinates, writer) do
    if coordinates == [0,0] do
      Writer.write(writer, Geo.Utils.repeat("0", 32))
    else
      x = coordinates |> hd |> Geo.Utils.float_to_hex(64) |> Integer.to_string(16)
      y = coordinates |> List.last |> Geo.Utils.float_to_hex(64) |> Integer.to_string(16)

      writer = Writer.write(writer, x)
      Writer.write(writer, y)
    end
  end

  defp encode_coordinates(:line_string, coordinates, writer) do
    number_of_points = Integer.to_string(length(coordinates), 16)
                       |> Geo.Utils.pad_left(8)


    writer = Writer.write(writer, number_of_points)

    {_nils, writer} = Enum.map_reduce(coordinates, writer, fn(pair, acc) ->
      acc = encode_coordinates(:point, pair, acc)
      {nil, acc}
    end)

    writer
  end

  defp encode_coordinates(:polygon, coordinates, writer) do
    number_of_lines = Integer.to_string(length(coordinates), 16)
                       |> Geo.Utils.pad_left(8)


    writer = Writer.write(writer, number_of_lines)

    {_nils, writer} = Enum.map_reduce(coordinates, writer, fn(line, acc) ->
      acc = encode_coordinates(:line_string, line, acc)
      {nil, acc}
    end)

    writer
  end

  defp encode_coordinates(type, coordinates, writer) when type == :multi_point or type == :multi_line_string or type == :multi_polygon do
    writer = Writer.write(writer, Integer.to_string(length(coordinates), 16) 
            |> Geo.Utils.pad_left(8))

    single_type = case type do
      :multi_point ->
        :point
      :multi_line_string ->
        :line_string
      :multi_polygon ->
        :polygon
    end

    geoms = Enum.map(coordinates, fn(geom) ->
      encode(%Geometry{ type: single_type, coordinates: geom }, Writer.get_endian(writer))
    end) |> Enum.join

    Writer.write_no_endian(writer, geoms)
  end

  def decode(wkb, geometries \\ []) do
    wkb_reader = Reader.start(wkb)
    { type, wkb_reader } = Reader.read(wkb_reader, 8)

    srid = nil

    type = String.to_integer(type, 16)

    if (type &&& 0x20000000) != 0 do
      { srid, wkb_reader } = Reader.read(wkb_reader, 8)
      srid = String.to_integer(srid, 16)
    end

    type = hex_to_type(type &&& 0xff)

    {coordinates, wkb_reader} = decode_coordinates(type, wkb_reader)

    if(type == :geometry_collection) do
      geometries = coordinates
      geometries = Enum.map(geometries, fn(x) -> %{ x | srid: srid } end)
    else
      geometries = geometries ++ [%Geometry{ type: type, coordinates: coordinates, srid: srid }]
    end

    if(Reader.eof?(wkb_reader)) do
      if(length(geometries) == 1) do
        hd(geometries)
      else
          geometries
      end
    else
      Reader.get_wkb(wkb_reader) |> decode(geometries)
    end
  end


  defp decode_coordinates(:point, wkb_reader) do
    {x, wkb_reader} = Reader.read(wkb_reader, 16)
    x = Geo.Utils.hex_to_float(x)

    {y, wkb_reader} = Reader.read(wkb_reader, 16)
    y = Geo.Utils.hex_to_float(y)
    { [x,y], wkb_reader }
  end

  defp decode_coordinates(:line_string, wkb_reader) do
    {number_of_points, wkb_reader} = Reader.read(wkb_reader, 8)
    number_of_points = number_of_points |> String.to_integer(16)

    Enum.map_reduce(Enum.to_list(0..(number_of_points-1)), wkb_reader, fn(_x, acc) ->
      decode_coordinates(:point, acc)
    end)
  end

  defp decode_coordinates(:polygon, wkb_reader) do
    {number_of_lines, wkb_reader} = Reader.read(wkb_reader, 8)

    number_of_lines = number_of_lines |> String.to_integer(16)

    Enum.map_reduce(Enum.to_list(0..(number_of_lines-1)), wkb_reader, fn(_x, acc) ->
      decode_coordinates(:line_string, acc)
    end)
  end

  defp decode_coordinates(type, wkb_reader) when type == :multi_point or type == :multi_line_string or type == :multi_polygon do
    {_number_of_items, wkb_reader} = Reader.read(wkb_reader, 8)
    geometries = Reader.get_wkb(wkb_reader) |> decode

    coordinates = Enum.map(geometries, fn(x) ->
      x.coordinates
    end)

    { coordinates, Reader.start("00") }
  end

  defp decode_coordinates(:geometry_collection, wkb_reader) do
    {_number_of_items, wkb_reader} = Reader.read(wkb_reader, 8)
    { decode(Reader.get_wkb(wkb_reader)), Reader.start("00") }
  end

  defp hex_to_type(type) do
    { key, _value } = Enum.find(@hex_type_map, fn({_key, value}) -> value == type end)
    key
  end

  defp type_to_hex(type, include_srid) do
    value = if include_srid, do: 0x20000000, else: 0x00000000
    value + @hex_type_map[type]
  end
end
