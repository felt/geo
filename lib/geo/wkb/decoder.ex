defmodule Geo.WKB.Decoder do
  @moduledoc false

  @point 0x00_00_00_01
  @point_m 0x40_00_00_01
  @point_z 0x80_00_00_01
  @point_zm 0xC0_00_00_01
  @line_string 0x00_00_00_02
  @line_string_m 0x40_00_00_02
  @line_string_z 0x80_00_00_02
  @polygon 0x00_00_00_03
  @polygon_z 0x80_00_00_03
  @multi_point 0x00_00_00_04
  @multi_point_m 0x40_00_00_04
  @multi_point_z 0x80_00_00_04
  @multi_line_string 0x00_00_00_05
  @multi_line_string_z 0x80_00_00_05
  @multi_polygon 0x00_00_00_06
  @multi_polygon_z 0x80_00_00_06
  @geometry_collection 0x00_00_00_07

  @wkbsridflag 0x20000000

  use Bitwise

  alias Geo.{
    Point,
    PointZ,
    PointM,
    PointZM,
    LineString,
    LineStringM,
    LineStringZ,
    Polygon,
    PolygonZ,
    GeometryCollection,
    MultiPoint,
    MultiPointM,
    MultiPointZ,
    MultiLineString,
    MultiLineStringZ,
    MultiPolygon,
    MultiPolygonZ
  }

  defguardp has_srid(type) when (type &&& @wkbsridflag) == @wkbsridflag

  defp remove_srid(type), do: type - @wkbsridflag

  for {endian, modifier} <- [{1, quote(do: little)}, {0, quote(do: big)}] do
    def decode(
          <<unquote(endian)::unquote(modifier)-integer-unsigned, type::32-unquote(modifier),
            srid::32-unquote(modifier), rest::bits>>
        )
        when has_srid(type) do
      do_decode(remove_srid(type), rest, srid, unquote(endian))
    end

    def decode(
          <<unquote(endian)::unquote(modifier)-integer-unsigned, type::32-unquote(modifier),
            rest::bits>>
        ) do
      do_decode(type, rest, nil, unquote(endian))
    end

    defp do_decode(
           @point,
           <<x::unquote(modifier)-float-64, y::unquote(modifier)-float-64, rest::bits>>,
           srid,
           unquote(endian)
         ) do
      {%Point{coordinates: {x, y}, srid: srid}, rest}
    end

    defp do_decode(
           @point_m,
           <<x::unquote(modifier)-float-64, y::unquote(modifier)-float-64,
             m::unquote(modifier)-float-64, rest::bits>>,
           srid,
           unquote(endian)
         ) do
      {%PointM{coordinates: {x, y, m}, srid: srid}, rest}
    end

    defp do_decode(
           @point_z,
           <<x::unquote(modifier)-float-64, y::unquote(modifier)-float-64,
             z::unquote(modifier)-float-64, rest::bits>>,
           srid,
           unquote(endian)
         ) do
      {%PointZ{coordinates: {x, y, z}, srid: srid}, rest}
    end

    defp do_decode(
           @point_zm,
           <<x::unquote(modifier)-float-64, y::unquote(modifier)-float-64,
             z::unquote(modifier)-float-64, m::unquote(modifier)-float-64, rest::bits>>,
           srid,
           unquote(endian)
         ) do
      {%PointZM{coordinates: {x, y, z, m}, srid: srid}, rest}
    end

    defp do_decode(
           @line_string,
           <<0::unquote(modifier)-32, "">>,
           srid,
           unquote(endian)
         ) do
      {%Geo.LineString{
         coordinates: [],
         properties: %{},
         srid: srid
       }, ""}
    end

    defp do_decode(
           @line_string,
           <<count::unquote(modifier)-32, rest::bits>>,
           srid,
           unquote(endian)
         ) do
      {coordinates, rest} =
        Enum.map_reduce(1..count, rest, fn _,
                                           <<x::unquote(modifier)-float-64,
                                             y::unquote(modifier)-float-64, rest::bits>> ->
          {%Point{coordinates: coordinates}, _rest} =
            do_decode(
              @point,
              <<x::unquote(modifier)-float-64, y::unquote(modifier)-float-64>>,
              nil,
              unquote(endian)
            )

          {coordinates, rest}
        end)

      {%LineString{coordinates: coordinates, srid: srid}, rest}
    end

    defp do_decode(
           @line_string_m,
           <<count::unquote(modifier)-32, rest::bits>>,
           srid,
           unquote(endian)
         ) do
      {coordinates, rest} =
        Enum.map_reduce(1..count, rest, fn _,
                                           <<x::unquote(modifier)-float-64,
                                             y::unquote(modifier)-float-64,
                                             z::unquote(modifier)-float-64, rest::bits>> ->
          {%PointM{coordinates: coordinates}, _rest} =
            do_decode(
              @point_m,
              <<x::unquote(modifier)-float-64, y::unquote(modifier)-float-64,
                z::unquote(modifier)-float-64>>,
              nil,
              unquote(endian)
            )

          {coordinates, rest}
        end)

      {%LineStringM{coordinates: coordinates, srid: srid}, rest}
    end

    defp do_decode(
           @line_string_z,
           <<count::unquote(modifier)-32, rest::bits>>,
           srid,
           unquote(endian)
         ) do
      {coordinates, rest} =
        Enum.map_reduce(1..count, rest, fn _,
                                           <<x::unquote(modifier)-float-64,
                                             y::unquote(modifier)-float-64,
                                             z::unquote(modifier)-float-64, rest::bits>> ->
          {%PointZ{coordinates: coordinates}, _rest} =
            do_decode(
              @point_z,
              <<x::unquote(modifier)-float-64, y::unquote(modifier)-float-64,
                z::unquote(modifier)-float-64>>,
              nil,
              unquote(endian)
            )

          {coordinates, rest}
        end)

      {%LineStringZ{coordinates: coordinates, srid: srid}, rest}
    end

    defp do_decode(
           @polygon,
           <<count::unquote(modifier)-32, rest::bits>>,
           srid,
           unquote(endian)
         ) do
      {coordinates, rest} =
        Enum.map_reduce(List.duplicate(1, count), rest, fn _, <<rest::bits>> ->
          {%LineString{coordinates: coordinates}, rest} =
            do_decode(
              @line_string,
              rest,
              nil,
              unquote(endian)
            )

          {coordinates, rest}
        end)

      {%Polygon{coordinates: coordinates, srid: srid}, rest}
    end

    defp do_decode(
           @polygon_z,
           <<count::unquote(modifier)-32, rest::bits>>,
           srid,
           unquote(endian)
         ) do
      {coordinates, rest} =
        Enum.map_reduce(List.duplicate(1, count), rest, fn _, <<rest::bits>> ->
          {%LineStringZ{coordinates: coordinates}, rest} =
            do_decode(
              @line_string_z,
              rest,
              nil,
              unquote(endian)
            )

          {coordinates, rest}
        end)

      {%PolygonZ{coordinates: coordinates, srid: srid}, rest}
    end

    defp do_decode(
           @multi_point,
           <<count::unquote(modifier)-32, rest::bits>>,
           srid,
           unquote(endian)
         ) do
      {coordinates, rest} =
        Enum.map_reduce(List.duplicate(1, count), rest, fn _, <<rest::bits>> ->
          {%Point{coordinates: coordinates}, rest} = decode(rest)

          {coordinates, rest}
        end)

      {%MultiPoint{coordinates: coordinates, srid: srid}, rest}
    end

    defp do_decode(
           @multi_point_m,
           <<count::unquote(modifier)-32, rest::bits>>,
           srid,
           unquote(endian)
         ) do
      {coordinates, rest} =
        Enum.map_reduce(List.duplicate(1, count), rest, fn _, <<rest::bits>> ->
          {%PointM{coordinates: coordinates}, rest} = decode(rest)

          {coordinates, rest}
        end)

      {%MultiPointM{coordinates: coordinates, srid: srid}, rest}
    end

    defp do_decode(
           @multi_point_z,
           <<count::unquote(modifier)-32, rest::bits>>,
           srid,
           unquote(endian)
         ) do
      {coordinates, rest} =
        Enum.map_reduce(List.duplicate(1, count), rest, fn _, <<rest::bits>> ->
          {%PointZ{coordinates: coordinates}, rest} = decode(rest)

          {coordinates, rest}
        end)

      {%MultiPointZ{coordinates: coordinates, srid: srid}, rest}
    end

    defp do_decode(
           @multi_line_string,
           <<count::unquote(modifier)-32, rest::bits>>,
           srid,
           unquote(endian)
         ) do
      {coordinates, rest} =
        Enum.map_reduce(List.duplicate(1, count), rest, fn _, <<rest::bits>> ->
          {%LineString{coordinates: coordinates}, rest} = decode(rest)

          {coordinates, rest}
        end)

      {%MultiLineString{coordinates: coordinates, srid: srid}, rest}
    end

    defp do_decode(
           @multi_line_string_z,
           <<count::unquote(modifier)-32, rest::bits>>,
           srid,
           unquote(endian)
         ) do
      {coordinates, rest} =
        Enum.map_reduce(List.duplicate(1, count), rest, fn _, <<rest::bits>> ->
          {%LineStringZ{coordinates: coordinates}, rest} = decode(rest)

          {coordinates, rest}
        end)

      {%MultiLineStringZ{coordinates: coordinates, srid: srid}, rest}
    end

    defp do_decode(
           @multi_polygon,
           <<count::unquote(modifier)-32, rest::bits>>,
           srid,
           unquote(endian)
         ) do
      {coordinates, rest} =
        Enum.map_reduce(List.duplicate(1, count), rest, fn _, <<rest::bits>> ->
          {%Polygon{coordinates: coordinates}, rest} = decode(rest)

          {coordinates, rest}
        end)

      {%MultiPolygon{coordinates: coordinates, srid: srid}, rest}
    end

    defp do_decode(
           @multi_polygon_z,
           <<count::unquote(modifier)-32, rest::bits>>,
           srid,
           unquote(endian)
         ) do
      {coordinates, rest} =
        Enum.map_reduce(List.duplicate(1, count), rest, fn _, <<rest::bits>> ->
          {%PolygonZ{coordinates: coordinates}, rest} = decode(rest)

          {coordinates, rest}
        end)

      {%MultiPolygonZ{coordinates: coordinates, srid: srid}, rest}
    end

    defp do_decode(
           @geometry_collection,
           <<count::unquote(modifier)-32, rest::bits>>,
           srid,
           unquote(endian)
         ) do
      {geometries, rest} =
        Enum.map_reduce(List.duplicate(1, count), rest, fn _, <<rest::bits>> ->
          decode(rest)
        end)

      geometries = Enum.map(geometries, fn geom -> %{geom | srid: srid} end)

      {%GeometryCollection{geometries: geometries, srid: srid}, rest}
    end
  end
end
