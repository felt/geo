defmodule Geo.WKB.IOEncoder do
  @moduledoc false

  @point 0x00_00_00_01
  @point_m 0x40_00_00_01
  @point_z 0x80_00_00_01
  @point_zm 0xC0_00_00_01
  @line_string 0x00_00_00_02
  @line_string_z 0x80_00_00_02
  @polygon 0x00_00_00_03
  @polygon_z 0x80_00_00_03
  @multi_point 0x00_00_00_04
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
    LineStringZ,
    Polygon,
    PolygonZ,
    MultiPoint,
    MultiPointZ,
    MultiLineString,
    MultiLineStringZ,
    MultiPolygon,
    MultiPolygonZ,
    GeometryCollection
  }

  defp add_srid(type), do: type + @wkbsridflag

  for {endian, endian_atom, modifier} <- [{1, :ndr, quote(do: little)}, {0, :xdr, quote(do: big)}] do
    def encode!(geom, unquote(endian_atom)) do
      {type, rest} = do_encode(geom, unquote(endian_atom))

      binary =
        if geom.srid do
          <<add_srid(type)::unquote(modifier)-32, geom.srid::unquote(modifier)-32>>
        else
          <<type::unquote(modifier)-32>>
        end

      IO.iodata_to_binary([unquote(endian), binary, rest])
    end

    def do_encode(%Point{coordinates: {x, y}}, unquote(endian_atom)) do
      {@point, [<<x::unquote(modifier)-float-64>>, <<y::unquote(modifier)-float-64>>]}
    end

    def do_encode(%PointZ{coordinates: {x, y, z}}, unquote(endian_atom)) do
      {@point_z,
       [
         <<x::unquote(modifier)-float-64>>,
         <<y::unquote(modifier)-float-64>>,
         <<z::unquote(modifier)-float-64>>
       ]}
    end

    def do_encode(%PointM{coordinates: {x, y, m}}, unquote(endian_atom)) do
      {@point_m,
       [
         <<x::unquote(modifier)-float-64>>,
         <<y::unquote(modifier)-float-64>>,
         <<m::unquote(modifier)-float-64>>
       ]}
    end
  end
end
