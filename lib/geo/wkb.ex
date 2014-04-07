defmodule Geo.WKB do
  alias Geo.Geometry
  use Bitwise

  def encode(geom, endian \\ :xdr) do
    if(is_list(geom)) do
      encode_collection(geom, endian)
    else
      _encode(geom, endian)
    end
  end

  def encode_collection(geom, endian) do
    endian_hex = if endian == :ndr, do: "01", else: "00"
    type =  type_to_hex(:geometry_collection, hd(geom).srid != nil)
            |> integer_to_binary(16)
            |> Geo.Utils.pad_left(8)

    srid = ""
    if hd(geom).srid do
      srid = integer_to_binary(hd(geom).srid, 16) |> Geo.Utils.pad_left(8)
    end

    count = integer_to_binary(Enum.count(geom), 16) |> Geo.Utils.pad_left(8)

    if endian == :ndr do
      type = Geo.Utils.reverse_byte_order(type)
      srid = Geo.Utils.reverse_byte_order(srid)
      count = Geo.Utils.reverse_byte_order(count)
    end

    wkb = "#{endian_hex}#{type}#{srid}#{count}" 

    coordinates = Enum.map(geom, 
      fn(x) -> 
        cond do
          x.type == :point ->
            "0101000000" <> encode_coordinates(:point, endian, x.coordinates)
          x.type == :line_string ->
            "0102000000" <> encode_coordinates(:line_string, endian, x.coordinates)
          x.type == :polygon ->
            "0103000000" <> encode_coordinates(:polygon, endian, x.coordinates)
          x.type == :multi_point ->
            "0104000000" <> encode_coordinates(:multi_point, endian, x.coordinates)
          x.type == :multi_line_string ->
            "0105000000" <> encode_coordinates(:multi_line_string, endian, x.coordinates)
          x.type == :multi_polygon ->
            "0106000000" <> encode_coordinates(:multi_polygon, endian, x.coordinates)
          true ->
            ""
        end
      end)

    coordinates = Enum.join(coordinates, "")

    wkb <> coordinates
  end

  def _encode(geom, endian) do
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
    if coordinates == [0,0] do
      Geo.Utils.repeat("0", 32)
    else
      x = coordinates |> hd |> Geo.Utils.float_to_hex(64) |> integer_to_binary(16)
      y = coordinates |> List.last |> Geo.Utils.float_to_hex(64) |> integer_to_binary(16)
      if endian == :ndr do
        x = Geo.Utils.reverse_byte_order(x)
        y = Geo.Utils.reverse_byte_order(y)
      end
      "#{x}#{y}"
    end
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

  defp encode_coordinates(type, endian, coordinates) when type == :multi_point or type == :multi_line_string or type == :multi_polygon do
    number_of_geoms = integer_to_binary(length(coordinates), 16) |> Geo.Utils.pad_left(8)

    if endian == :ndr do
      number_of_geoms = Geo.Utils.reverse_byte_order(number_of_geoms)
    end

    {separator, single_type} = get_separator_and_single_type(type)

    geoms = Enum.map(coordinates, fn(geom) ->
      separator <> encode_coordinates(single_type, endian, geom)
    end) |> Enum.join

    number_of_geoms <> geoms
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

    if(type == :geometry_collection) do
      decode_geometry_collection(coordinate_binary, srid, endian)
    else
      coordinates = decode_coordinates(type, coordinate_binary, endian)
      Geometry.new type: type, coordinates: coordinates, srid: srid
    end
  end

  defp decode_geometry_collection(coordinate_binary, srid, endian) do
    {_, formatted_string} = Enum.map_reduce(["0101000000","0102000000","0103000000","0104000000", "0105000000","0106000000"],coordinate_binary,fn(x, acc) -> {nil, String.replace(acc, x, "-#{x}:")}end)
    geometry_strings = String.split(formatted_string, "-") |> Enum.drop(1)
    geometry_strings = Enum.map(geometry_strings, fn(x) -> 
      geom = String.split(x,":")

      {coordinates, type} = cond do
        hd(geom) == "0101000000" ->
          { decode_coordinates(:point, List.last(geom), endian), :point }
        hd(geom) ==  "0102000000" ->
          { decode_coordinates(:line_string, List.last(geom), endian), :line_string }
        hd(geom) == "0103000000" ->
          { decode_coordinates(:polygon, List.last(geom), endian), :polygon }
        hd(geom) == "0104000000" ->
          { decode_coordinates(:multi_point, List.last(geom), endian), :multi_point }
        hd(geom) == "0105000000" ->
          { decode_coordinates(:multi_line_string, List.last(geom), endian), :multi_line_string }
        hd(geom) == "0106000000" ->
          { decode_coordinates(:multi_polygon, List.last(geom), endian), :multi_polygon }
        true ->
          {[],:geometry}
      end

      Geometry.new type: type, coordinates: coordinates, srid: srid
    end)

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

  defp decode_coordinates(type, coordinate_binary, endian) when type == :multi_point or type == :multi_line_string or type == :multi_polygon do
    coordinate_binary = String.slice(coordinate_binary, 8, String.length(coordinate_binary))

    {separator, single_type} = get_separator_and_single_type(type)

    String.split(coordinate_binary, separator) 
    |> Enum.drop(1)
    |> Enum.map(&decode_coordinates(single_type, &1, endian))
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
      4 ->
        :multi_point
      5 ->
        :multi_line_string
      6 ->
        :multi_polygon
      _ ->
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
      _ ->
        value + 0x07
    end
  end


  defp get_separator_and_single_type(multi_type) do
    case multi_type do
      :multi_point ->
        {"0101000000", :point }
      :multi_line_string ->
        {"0102000000", :line_string }
      _ ->
        {"0103000000", :polygon }
    end
  end
end
