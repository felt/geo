defmodule Geo.WKB do
  alias Geo.Geometry
  use Bitwise

  def encode(geom) do

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

    type = get_type(type &&& 0xff)

    Geometry.new type: type, coordinates: [x, y], srid: srid
  end

  def get_type(type) do
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
