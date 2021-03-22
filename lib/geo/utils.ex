defmodule Geo.Utils do
  @moduledoc false
  use Bitwise

  @doc """
  Turns a hex string or an integer of base 16 into its floating point
  representation.

  Takes an optional endian atom. Either :xdr for big endian or :ndr for little
  endian. Defaults to :xdr

  # Examples

      iex> Geo.Utils.hex_to_float("40000000")
      2.0

      iex> Geo.Utils.hex_to_float(0x40000000)
      2.0

      iex> Geo.Utils.hex_to_float("3ff0000000000000")
      1.0

      iex> Geo.Utils.hex_to_float(0x3ff0000000000000)
      1.0

  """
  def hex_to_float(hex) when is_integer(hex) do
    hex_to_float(Integer.to_string(hex, 16))
  end

  def hex_to_float(hex) when is_binary(hex) do
    case bit_size(hex) do
      x when x <= 64 ->
        <<value::float-32>> = <<String.to_integer(hex, 16)::integer-32>>
        value

      128 ->
        <<value::float-64>> = <<String.to_integer(hex, 16)::integer-64>>
        value
    end
  end

  @doc """
  Turns a float into a hex value. The size can either be 32 or 64.
  """
  def float_to_hex(float, 64) do
    <<value::integer-64>> = <<float::float-64>>
    value
  end

  def float_to_hex(float, 32) do
    <<value::integer-32>> = <<float::float-32>>
    value
  end

  @doc """
  Reverses the byte order of the given hex string.

  ## Examples

      iex> Geo.Utils.reverse_byte_order("00000004")
      "40000000"

      iex> Geo.Utils.reverse_byte_order("E6100000")
      "000010E6"

  """
  def reverse_byte_order("") do
    ""
  end

  def reverse_byte_order(hex) do
    do_reverse_byte_order(hex, "")
  end

  defp do_reverse_byte_order("", acc) do
    acc
  end

  defp do_reverse_byte_order(<<a, b, rest::binary>>, acc) do
    do_reverse_byte_order(rest, <<a, b, acc::binary>>)
  end

  @doc """
  Adds 0's to the left of hex string.
  """
  def pad_left(hex, size) when byte_size(hex) >= size do
    hex
  end

  def pad_left(hex, size) do
    String.duplicate("0", size - byte_size(hex)) <> hex
  end

  def binary_to_endian(<<48, 49>>) do
    :ndr
  end

  def binary_to_endian(<<48, 48>>) do
    :xdr
  end

  def hex_to_type(0x01) do
    %Geo.Point{}
  end

  def hex_to_type(0x40_00_00_01) do
    %Geo.PointM{}
  end

  def hex_to_type(0x80_00_00_01) do
    %Geo.PointZ{}
  end

  def hex_to_type(0xC0_00_00_01) do
    %Geo.PointZM{}
  end

  def hex_to_type(0x02) do
    %Geo.LineString{}
  end

  def hex_to_type(0x80_00_00_02) do
    %Geo.LineStringZ{}
  end

  def hex_to_type(0x03) do
    %Geo.Polygon{}
  end

  def hex_to_type(0x80_00_00_03) do
    %Geo.PolygonZ{}
  end

  def hex_to_type(0x04) do
    %Geo.MultiPoint{}
  end

  def hex_to_type(0x80_00_00_04) do
    %Geo.MultiPointZ{}
  end

  def hex_to_type(0x05) do
    %Geo.MultiLineString{}
  end

  def hex_to_type(0x80_00_00_05) do
    %Geo.MultiLineStringZ{}
  end

  def hex_to_type(0x06) do
    %Geo.MultiPolygon{}
  end

  def hex_to_type(0x80_00_00_06) do
    %Geo.MultiPolygonZ{}
  end

  def hex_to_type(0x07) do
    %Geo.GeometryCollection{}
  end

  def type_to_hex(geom, true) do
    value = 0x20000000
    value + do_type_to_hex(geom)
  end

  def type_to_hex(geom, false) do
    value = 0x00000000
    value + do_type_to_hex(geom)
  end

  def do_type_to_hex(%Geo.Point{}) do
    0x01
  end

  def do_type_to_hex(%Geo.PointM{}) do
    0x40_00_00_01
  end

  def do_type_to_hex(%Geo.PointZ{}) do
    0x80_00_00_01
  end

  def do_type_to_hex(%Geo.PointZM{}) do
    0xC0_00_00_01
  end

  def do_type_to_hex(%Geo.LineString{}) do
    0x02
  end

  def do_type_to_hex(%Geo.LineStringZ{}) do
    0x80_00_00_02
  end

  def do_type_to_hex(%Geo.Polygon{}) do
    0x03
  end

  def do_type_to_hex(%Geo.PolygonZ{}) do
    0x80_00_00_03
  end

  def do_type_to_hex(%Geo.MultiPoint{}) do
    0x04
  end

  def do_type_to_hex(%Geo.MultiPointZ{}) do
    0x80_00_00_04
  end

  def do_type_to_hex(%Geo.MultiLineString{}) do
    0x05
  end

  def do_type_to_hex(%Geo.MultiLineStringZ{}) do
    0x80_00_00_05
  end

  def do_type_to_hex(%Geo.MultiPolygon{}) do
    0x06
  end

  def do_type_to_hex(%Geo.MultiPolygonZ{}) do
    0x80_00_00_06
  end

  def do_type_to_hex(%Geo.GeometryCollection{}) do
    0x07
  end
end
