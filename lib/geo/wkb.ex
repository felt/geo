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

    x = geom.coordinates
        |> hd
        |> Geo.Utils.float_to_hex(64)
        |> integer_to_binary(16)

    y = geom.coordinates
        |> List.last
        |> Geo.Utils.float_to_hex(64)
        |> integer_to_binary(16)

    if endian == :ndr do
      type = Geo.Utils.reverse_byte_order(type)
      srid = Geo.Utils.reverse_byte_order(srid)
      x = Geo.Utils.reverse_byte_order(x)
      y = Geo.Utils.reverse_byte_order(y)
    end

    "#{endian_hex}#{type}#{srid}#{x}#{y}"
  end

  def type_to_hex(type, include_srid \\ false) do
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

    if srid != nil do
      x = Geo.Utils.hex_to_float(String.slice(wkb, 18,16), endian)
      y = Geo.Utils.hex_to_float(String.slice(wkb, 34,16), endian)
    else
      x = Geo.Utils.hex_to_float(String.slice(wkb, 10,16), endian)
      y = Geo.Utils.hex_to_float(String.slice(wkb, 26,16), endian)
    end

    type = hex_to_type(type &&& 0xff)

    Geometry.new type: type, coordinates: [x, y], srid: srid
  end

  def hex_to_type(type) do
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
end
