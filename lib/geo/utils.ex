defmodule Geo.Utils do
  @moduledoc false
  use Bitwise

  @doc """
  Turns a hex string or an integer of base 16 into its floating point
  representation.

  Takes an optional endian atom. Either :xdr for big endian or :ndr for little
  endian. Defaults to :xdr

  `
    Geo.Utils.hex_to_float("40000000")
    2.0

    Geo.Utils.hex_to_float(0x40000000)
    2.0

    Geo.Utils.hex_to_float("3ff0000000000000")
    1.0

    Geo.Utils.hex_to_float(0x3ff0000000000000)
    1.0
  `
  """
  def hex_to_float(hex) when is_integer(hex) or is_binary(hex) do
    hex = if is_integer(hex), do: Integer.to_string(hex, 16), else: hex

    case bit_size(hex) do
      64 ->
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
  def float_to_hex(float, size) do
    case size do
      32 ->
        <<value::integer-32>> = <<float::float-32>>
        value

      64 ->
        <<value::integer-64>> = <<float::float-64>>
        value
    end
  end

  @doc """
  Reverses the byte order of the given hex string.

  ```
  Geo.Utils.reverse_byte_order("00000004")
  "40000000"

  Geo.Utils.reverse_byte_order("E6100000")
  "000010E6"
  ```
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

  defp do_reverse_byte_order(<<a, b, rest :: binary>>, acc) do
    do_reverse_byte_order(rest, <<a, b, acc :: binary>>)
  end

  @doc """
  Adds 0's to the left of hex string
  """
  def pad_left(hex, size) do
    if byte_size(hex) == size do
      hex
    else
      repeat("0", size - byte_size(hex)) <> hex
    end
  end

  @doc """
  Repeats the char count number of times
  """
  def repeat(char, count) do
    Enum.map(1..count, fn _x -> char end) |> Enum.join()
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

  def hex_to_type(0x03) do
    %Geo.Polygon{}
  end

  def hex_to_type(0x04) do
    %Geo.MultiPoint{}
  end

  def hex_to_type(0x05) do
    %Geo.MultiLineString{}
  end

  def hex_to_type(0x06) do
    %Geo.MultiPolygon{}
  end

  def hex_to_type(0x07) do
    %Geo.GeometryCollection{}
  end

  def type_to_hex(geom, include_srid) do
    value = if include_srid, do: 0x20000000, else: 0x00000000
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

  def do_type_to_hex(%Geo.Polygon{}) do
    0x03
  end

  def do_type_to_hex(%Geo.MultiPoint{}) do
    0x04
  end

  def do_type_to_hex(%Geo.MultiLineString{}) do
    0x05
  end

  def do_type_to_hex(%Geo.MultiPolygon{}) do
    0x06
  end

  def do_type_to_hex(%Geo.GeometryCollection{}) do
    0x07
  end
end
