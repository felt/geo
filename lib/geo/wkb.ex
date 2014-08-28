defmodule Geo.WKB do
  alias Geo.Geometry
  use Bitwise

	defmodule WKBReader do
		defstruct wkb: nil, endian: :xdr
	end

  defmodule WKBWriter do
    defstruct wkb: nil, endian: :xdr
  end

  defp reader_init(wkb) do
    endian = if String.to_integer(String.slice(wkb, 0,2), 16) > 0 do
      :ndr
    else
      :xdr
    end

    %WKBReader{ wkb: String.slice(wkb, 2, String.length(wkb)), endian: endian }
  end

  defp reader_read(count, reader) do
    value = String.slice(reader.wkb, 0, count)

    if reader.endian == :ndr do
      value = Geo.Utils.reverse_byte_order(value)
    end

    { value, %{ reader | wkb: String.slice(reader.wkb, count, String.length(reader.wkb)) } }
  end

  defp reader_eof?(reader) do
    String.length(reader.wkb) == 0
  end


  defp writer_write(value, writer) do

    if(writer.endian == :ndr)do
      value = Geo.Utils.reverse_byte_order(value)
    end

    %{ writer | wkb: writer.wkb <> value }
  end

  defp writer_write_no_endian(value, writer) do
    %{ writer | wkb: writer.wkb <> value }
  end





  def encode(geom, endian \\ :xdr) do
    endian_hex = if endian == :ndr, do: "01", else: "00"
    writer = %WKBWriter{ wkb: endian_hex, endian: endian }
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

    writer = writer_write(type, writer)
    writer = writer_write(srid, writer)
    writer = writer_write(count, writer)

    coordinates = Enum.map(geom,
      fn(x) ->
        encode(%Geometry{ type: x.type, coordinates: x.coordinates }, writer.endian)
      end)

    coordinates = Enum.join(coordinates, "")

    writer.wkb <> coordinates
  end

  def do_encode(geom, writer) do
    type =  type_to_hex(geom.type, geom.srid != nil)
            |> Integer.to_string(16)
            |> Geo.Utils.pad_left(8)

    srid = ""
    if geom.srid do
      srid = Integer.to_string(geom.srid, 16) |> Geo.Utils.pad_left(8)
    end

    writer = writer_write(type, writer)
    writer = writer_write(srid, writer)

    writer = encode_coordinates(geom.type, geom.coordinates, writer)
    writer.wkb
  end

  defp encode_coordinates(:point, coordinates, writer) do
    if coordinates == [0,0] do
      writer_write(Geo.Utils.repeat("0", 32), writer)
    else
      x = coordinates |> hd |> Geo.Utils.float_to_hex(64) |> Integer.to_string(16)
      y = coordinates |> List.last |> Geo.Utils.float_to_hex(64) |> Integer.to_string(16)

      writer = writer_write(x, writer)
      writer_write(y, writer)
    end
  end

  defp encode_coordinates(:line_string, coordinates, writer) do
    number_of_points = Integer.to_string(length(coordinates), 16)
                       |> Geo.Utils.pad_left(8)


    writer = writer_write(number_of_points, writer)

    {_nils, writer} = Enum.map_reduce(coordinates, writer, fn(pair, acc) ->
      acc = encode_coordinates(:point, pair, acc)
      {nil, acc}
    end)

    writer
  end

  defp encode_coordinates(:polygon, coordinates, writer) do
    number_of_lines = Integer.to_string(length(coordinates), 16)
                       |> Geo.Utils.pad_left(8)


    writer = writer_write(number_of_lines, writer)

    {_nils, writer} = Enum.map_reduce(coordinates, writer, fn(line, acc) ->
      acc = encode_coordinates(:line_string, line, acc)
      {nil, acc}
    end)

    writer
  end

  defp encode_coordinates(type, coordinates, writer) when type == :multi_point or type == :multi_line_string or type == :multi_polygon do

    writer = writer_write(Integer.to_string(length(coordinates), 16) |> Geo.Utils.pad_left(8), writer)

    single_type = case type do
      :multi_point ->
        :point
      :multi_line_string ->
        :line_string
      :multi_polygon ->
        :polygon
    end

    geoms = Enum.map(coordinates, fn(geom) ->
      encode(%Geometry{ type: single_type, coordinates: geom }, writer.endian)
    end) |> Enum.join

    writer_write_no_endian(geoms, writer)
  end

  def decode(wkb, geometries \\ []) do
    wkb_reader = reader_init(wkb)
    { type, wkb_reader } = reader_read(8, wkb_reader)

    srid = nil

    type = String.to_integer(type, 16)

    if (type &&& 0x20000000) != 0 do
      { srid, wkb_reader } = reader_read(8, wkb_reader)
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

    if(reader_eof?(wkb_reader)) do
      if(length(geometries) == 1) do
        hd(geometries)
      else
          geometries
      end
    else
      decode(wkb_reader.wkb, geometries)
    end
  end


  defp decode_coordinates(:point, wkb_reader) do
    {x, wkb_reader} = reader_read(16, wkb_reader)
    x = Geo.Utils.hex_to_float(x)

    {y, wkb_reader} = reader_read(16, wkb_reader)
    y = Geo.Utils.hex_to_float(y)
    { [x,y], wkb_reader }
  end

  defp decode_coordinates(:line_string, wkb_reader) do
    {number_of_points, wkb_reader} = reader_read(8, wkb_reader)
    number_of_points = number_of_points |> String.to_integer(16)

    Enum.map_reduce(Enum.to_list(0..(number_of_points-1)), wkb_reader, fn(_x, acc) ->
      decode_coordinates(:point, acc)
    end)
  end

  defp decode_coordinates(:polygon, wkb_reader) do
    {number_of_lines, wkb_reader} = reader_read(8, wkb_reader)

    number_of_lines = number_of_lines |> String.to_integer(16)

    Enum.map_reduce(Enum.to_list(0..(number_of_lines-1)), wkb_reader, fn(_x, acc) ->
      decode_coordinates(:line_string, acc)
    end)
  end

  defp decode_coordinates(type, wkb_reader) when type == :multi_point or type == :multi_line_string or type == :multi_polygon do
    {_number_of_items, wkb_reader} = reader_read(8, wkb_reader)
    geometries = decode(wkb_reader.wkb)

    coordinates = Enum.map(geometries, fn(x) ->
      x.coordinates
    end)

    { coordinates, reader_init("00") }
  end

  defp decode_coordinates(:geometry_collection, wkb_reader) do
    {_number_of_items, wkb_reader} = reader_read(8, wkb_reader)
    { decode(wkb_reader.wkb), reader_init("00") }
  end

  defp hex_to_type(type) do
    case type do
      1 ->
        :point
      2 ->
        :line_string
      3 ->
        :polygon
      4 ->
        :multi_point
      5 ->
        :multi_line_string
      6 ->
        :multi_polygon
      7 ->
        :geometry_collection
    end
  end

  defp type_to_hex(type, include_srid) do
    value = if include_srid, do: 0x20000000, else: 0x00000000

    case type do
      :point ->
        value + 0x01
      :line_string ->
        value + 0x02
      :polygon ->
        value + 0x03
      :multi_point ->
        value + 0x04
      :multi_line_string ->
        value + 0x05
      :multi_polygon ->
        value + 0x06
      :geometry_collection ->
        value + 0x07
    end
  end
end
