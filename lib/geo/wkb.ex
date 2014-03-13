defmodule Geo.WKB do
  alias Geo.Geometry
  use Bitwise

  def encode(geom, endian \\ :xdr) do
    endian_hex = if endian == :ndr, do: "01", else: "00"
    type =  type_to_hex(geom.type, geom.srid != nil)
            |> integer_to_binary(16)
            |> Geo.Utils.pad_left(8)

    srid = ""
    if geom.srid do
      srid = integer_to_binary(geom.srid, 16) |> Geo.Utils.pad_left(8)
    end

    if endian == :ndr do
      type = Geo.Utils.reverse_byte_order(type)
      srid = Geo.Utils.reverse_byte_order(srid)
    end

    "#{endian_hex}#{type}#{srid}" <> encode_coordinates(geom.type, endian, geom.coordinates)
  end

  defp encode_coordinates(:point, endian, coordinates) do

    x = coordinates |> hd |> Geo.Utils.float_to_hex(64) |> integer_to_binary(16)
    y = coordinates |> List.last |> Geo.Utils.float_to_hex(64) |> integer_to_binary(16)

    if endian == :ndr do
      x = Geo.Utils.reverse_byte_order(x)
      y = Geo.Utils.reverse_byte_order(y)
    end

    "#{x}#{y}"
  end

  defp encode_coordinates(:line_string, endian, coordinates) do
    number_of_points = integer_to_binary(length(coordinates), 16)
                       |> Geo.Utils.pad_left(8)

    if endian == :ndr do
      number_of_points = Geo.Utils.reverse_byte_order(number_of_points)
    end

    points = Enum.map(coordinates, fn(pair) ->
      encode_coordinates(:point, endian, pair)
    end) |> Enum.join

    number_of_points <> points
  end

  defp encode_coordinates(:polygon, endian, coordinates) do
    number_of_lines = integer_to_binary(length(coordinates), 16)
                       |> Geo.Utils.pad_left(8)

    if endian == :ndr do
      number_of_lines = Geo.Utils.reverse_byte_order(number_of_lines)
    end

    points = Enum.map(coordinates, fn(line) ->
      encode_coordinates(:line_string, endian, line)
    end) |> Enum.join

    number_of_lines <> points
  end

  def decode(wkb) do
    endian = binary_to_integer(String.slice(wkb, 0,2), 16)
    type = String.slice(wkb, 2,8)
    srid = nil

    if endian > 0 do
      endian = :ndr
      type = Geo.Utils.reverse_byte_order(String.slice(wkb, 2,8))
    else
      endian = :xdr
    end

    type = binary_to_integer(type, 16)

    if (type &&& 0x20000000) != 0 do
      case endian do
        :ndr ->
          srid = Geo.Utils.reverse_byte_order(String.slice(wkb, 10,8))
        _ ->
          srid = String.slice(wkb, 10,8)
      end

      srid = binary_to_integer(srid, 16)
    end

    index = if srid != nil, do: 18, else: 10

    type = hex_to_type(type &&& 0xff)
    coordinate_binary = String.slice(wkb, index, String.length(wkb))

    coordinates = decode_coordinates(type, coordinate_binary, endian)
    Geometry.new type: type, coordinates: coordinates, srid: srid
  end

  defp decode_coordinates(:point, coordinate_binary, endian) do
    x = String.slice(coordinate_binary, 0,16) |> Geo.Utils.hex_to_float(endian)
    y = String.slice(coordinate_binary, 16,16) |> Geo.Utils.hex_to_float(endian)
    [x,y]
  end

  defp decode_coordinates(:line_string, coordinate_binary, endian) do
    number_of_points = String.slice(coordinate_binary, 0, 8)

    if endian == :ndr do
      number_of_points = Geo.Utils.reverse_byte_order(number_of_points)
    end

    number_of_points = number_of_points |> binary_to_integer(16)

    Enum.map(Enum.to_list(0..(number_of_points-1)), fn(x) ->
      pair = String.slice(coordinate_binary, 8 + (32 * x), 32)
      decode_coordinates(:point, pair, endian)
    end)
  end

  defp decode_coordinates(:polygon, coordinate_binary, endian) do
    number_of_lines = String.slice(coordinate_binary, 0, 8)

    if endian == :ndr do
      number_of_lines = Geo.Utils.reverse_byte_order(number_of_lines)
    end

    number_of_lines = number_of_lines |> binary_to_integer(16)
    line_strings = get_line_strings(String.slice(coordinate_binary, 8, String.length(coordinate_binary)), number_of_lines, endian)

    Enum.map(line_strings, fn(x) ->
      decode_coordinates(:line_string, x, endian)
    end)
  end

  def get_line_strings(coordinate_binary, number_of_lines, endian, coordinates \\ []) do
    if coordinate_binary == "" or number_of_lines <= 0 do
      coordinates
    else
      number_of_points = String.slice(coordinate_binary, 0, 8)

      if endian == :ndr do
        number_of_points = Geo.Utils.reverse_byte_order(number_of_points)
      end

      number_of_points = number_of_points |> binary_to_integer(16)

      string = String.slice(coordinate_binary, 0, 8 + (32 * number_of_points))
      remaining = String.slice(coordinate_binary, 8 + (32 * number_of_points), String.length(coordinate_binary))

      get_line_strings(remaining, number_of_lines - 1, endian, Enum.concat(coordinates, [string]))
    end
  end

  defp hex_to_type(type) do
    case type do
      1 ->
        :point
      2 ->
        :line_string
      3 ->
        :polygon
      true ->
        :geometry
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
      true ->
        value + 0x04
    end
  end
end
