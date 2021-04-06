defmodule Geo.WKB.IODecoder do
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

  @wkbsridflag 0x20000000

  defguardp has_srid(type) when (type &&& @wkbsridflag) == @wkbsridflag

  defp remove_srid(type), do: type - @wkbsridflag

  @doc """
  Takes a WKB string and returns a Geometry.
  """
  @spec decode_iodata(iodata()) :: {:ok, Geo.geometry()} | {:error, Exception.t()}
  def decode_iodata(wkb) do
    {:ok, decode_iodata!(wkb)}
  rescue
    exception ->
      {:error, exception}
  end

  @doc """
  Takes a WKB string and returns a Geometry.
  """
  @spec decode_iodata!(iodata()) :: Geo.geometry() | no_return
  def decode_iodata!(wkb)

  def decode_iodata!(<<0, type::32-big, rest::bits>>) do
    rest =
      rest
      |> :binary.decode_unsigned(:big)
      |> :binary.encode_unsigned(:little)

    IO.inspect(type == 0x80_00_00_02)

    wkb = <<1, type::32-little, rest::bits>>
    IO.inspect(wkb)

    decode_iodata!(wkb)
  end

  def decode_iodata!(<<1, type::32-little, srid::32-little, rest::bits>>)
      when has_srid(type) do
    do_decode_ndr(remove_srid(type), rest, srid)
  end

  def decode_iodata!(<<1, type::32-little, rest::bits>>) do
    do_decode_ndr(type, rest, nil)
  end

  defp do_decode_ndr(0x00_00_00_01, <<x::little-float-64, y::little-float-64>>, srid) do
    %Point{coordinates: {x, y}, srid: srid}
  end

  defp do_decode_ndr(
         0x40_00_00_01,
         <<x::little-float-64, y::little-float-64, m::little-float-64>>,
         srid
       ) do
    %PointM{coordinates: {x, y, m}, srid: srid}
  end

  defp do_decode_ndr(
         0x80_00_00_01,
         <<x::little-float-64, y::little-float-64, z::little-float-64>>,
         srid
       ) do
    %PointZ{coordinates: {x, y, z}, srid: srid}
  end

  defp do_decode_ndr(
         0xC0_00_00_01,
         <<x::little-float-64, y::little-float-64, z::little-float-64, m::little-float-64>>,
         srid
       ) do
    %PointZM{coordinates: {x, y, z, m}, srid: srid}
  end

  defp do_decode_ndr(
         0x00_00_00_02,
         <<number_of_points::little-32, rest::bits>>,
         srid
       ) do
    coordinates = decode_linestring_points_ndr(number_of_points, rest, [])

    %LineString{coordinates: coordinates, srid: srid}
  end

  defp do_decode_ndr(
         0x80_00_00_02,
         <<number_of_points::little-32, rest::bits>>,
         srid
       ) do
    coordinates = decode_linestringz_points_ndr(number_of_points, rest, [])

    %LineStringZ{coordinates: coordinates, srid: srid}
  end

  defp decode_linestring_points_ndr(0, _bits, data) do
    Enum.reverse(data)
  end

  defp decode_linestring_points_ndr(
         number_of_points,
         <<x::little-float-64, y::little-float-64, rest::bits>>,
         data
       ) do
    %Point{coordinates: coordinates} =
      do_decode_ndr(0x00_00_00_01, <<x::little-float-64, y::little-float-64>>, nil)

    data = [coordinates | data]

    decode_linestring_points_ndr(number_of_points - 1, rest, data)
  end

  defp decode_linestringz_points_ndr(0, _bits, data) do
    Enum.reverse(data)
  end

  defp decode_linestringz_points_ndr(
         number_of_points,
         <<x::little-float-64, y::little-float-64, z::little-float-64, rest::bits>>,
         data
       ) do
    %PointZ{coordinates: coordinates} =
      do_decode_ndr(
        0x80_00_00_01,
        <<x::little-float-64, y::little-float-64, z::little-float-64>>,
        nil
      )

    data = [coordinates | data]

    decode_linestringz_points_ndr(number_of_points - 1, rest, data)
  end
end
