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

  for {endian, modifier} <- [{1, {:little, [], Elixir}}, {0, {:big, [], Elixir}}] do
    def decode_iodata!(
          <<unquote(endian)::unquote(modifier)-integer-unsigned, type::32-unquote(modifier),
            srid::32-unquote(modifier), rest::bits>>
        )
        when has_srid(type) do
      do_decode(remove_srid(type), rest, srid, unquote(endian)) |> elem(0)
    end

    def decode_iodata!(
          <<unquote(endian)::unquote(modifier)-integer-unsigned, type::32-unquote(modifier),
            rest::bits>>
        ) do
      do_decode(type, rest, nil, unquote(endian)) |> elem(0)
    end

    defp do_decode(
           0x00_00_00_01,
           <<x::unquote(modifier)-float-64, y::unquote(modifier)-float-64>>,
           srid,
           unquote(endian)
         ) do
      {%Point{coordinates: {x, y}, srid: srid}, <<>>}
    end

    defp do_decode(
           0x40_00_00_01,
           <<x::unquote(modifier)-float-64, y::unquote(modifier)-float-64,
             m::unquote(modifier)-float-64>>,
           srid,
           unquote(endian)
         ) do
      {%PointM{coordinates: {x, y, m}, srid: srid}, <<>>}
    end

    defp do_decode(
           0x80_00_00_01,
           <<x::unquote(modifier)-float-64, y::unquote(modifier)-float-64,
             z::unquote(modifier)-float-64>>,
           srid,
           unquote(endian)
         ) do
      {%PointZ{coordinates: {x, y, z}, srid: srid}, <<>>}
    end

    defp do_decode(
           0xC0_00_00_01,
           <<x::unquote(modifier)-float-64, y::unquote(modifier)-float-64,
             z::unquote(modifier)-float-64, m::unquote(modifier)-float-64>>,
           srid,
           unquote(endian)
         ) do
      {%PointZM{coordinates: {x, y, z, m}, srid: srid}, <<>>}
    end

    defp do_decode(
           0x00_00_00_02,
           <<number_of_points::unquote(modifier)-32, rest::bits>>,
           srid,
           unquote(endian)
         ) do
      {coordinates, rest} = decode_linestring(number_of_points, rest, [], unquote(endian))

      {%LineString{coordinates: coordinates, srid: srid}, rest}
    end

    defp do_decode(
           0x80_00_00_02,
           <<number_of_points::unquote(modifier)-32, rest::bits>>,
           srid,
           unquote(endian)
         ) do
      {coordinates, rest} = decode_linestringz(number_of_points, rest, [], unquote(endian))

      {%LineStringZ{coordinates: coordinates, srid: srid}, rest}
    end

    defp do_decode(
           0x00_00_00_03,
           <<number_of_linestrings::unquote(modifier)-32, rest::bits>>,
           srid,
           unquote(endian)
         ) do
      {coordinates, rest} = decode_polygon(number_of_linestrings, rest, [], unquote(endian))

      {%Polygon{coordinates: coordinates, srid: srid}, rest}
    end

    defp decode_linestring(0, bits, data, _) do
      {Enum.reverse(data), bits}
    end

    defp decode_linestring(
           number_of_points,
           <<x::unquote(modifier)-float-64, y::unquote(modifier)-float-64, rest::bits>>,
           data,
           unquote(endian)
         ) do
      {%Point{coordinates: coordinates}, _rest} =
        do_decode(
          0x00_00_00_01,
          <<x::unquote(modifier)-float-64, y::unquote(modifier)-float-64>>,
          nil,
          unquote(endian)
        )

      data = [coordinates | data]

      decode_linestring(number_of_points - 1, rest, data, unquote(endian))
    end

    defp decode_linestringz(0, bits, data, _) do
      {Enum.reverse(data), bits}
    end

    defp decode_linestringz(
           number_of_points,
           <<x::unquote(modifier)-float-64, y::unquote(modifier)-float-64,
             z::unquote(modifier)-float-64, rest::bits>>,
           data,
           unquote(endian)
         ) do
      {%PointZ{coordinates: coordinates}, _rest} =
        do_decode(
          0x80_00_00_01,
          <<x::unquote(modifier)-float-64, y::unquote(modifier)-float-64,
            z::unquote(modifier)-float-64>>,
          nil,
          unquote(endian)
        )

      data = [coordinates | data]

      decode_linestringz(number_of_points - 1, rest, data, unquote(endian))
    end

    defp decode_polygon(0, bits, data, _) do
      {Enum.reverse(data), bits}
    end

    defp decode_polygon(
           number_of_linestrings,
           bits,
           data,
           unquote(endian)
         ) do
      {%LineString{coordinates: coordinates}, rest} =
        do_decode(
          0x00_00_00_02,
          bits,
          nil,
          unquote(endian)
        )

      data = [coordinates | data]

      decode_polygon(number_of_linestrings - 1, rest, data, unquote(endian))
    end
  end
end
