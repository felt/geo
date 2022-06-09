defmodule Geo.WKB.Encoder do
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
    MultiPoint,
    MultiPointM,
    MultiPointZ,
    MultiLineString,
    MultiLineStringZ,
    MultiPolygon,
    MultiPolygonZ,
    GeometryCollection
  }

  defp add_srid(type), do: type + @wkbsridflag

  def encode!(geom, endian \\ :ndr)

  for {endian, endian_atom, modifier} <- [{1, :ndr, quote(do: little)}, {0, :xdr, quote(do: big)}] do
    def encode!(geom, unquote(endian_atom)) do
      {type, rest} = do_encode(geom, unquote(endian_atom))

      binary =
        if geom.srid do
          <<add_srid(type)::unquote(modifier)-32, geom.srid::unquote(modifier)-32>>
        else
          <<type::unquote(modifier)-32>>
        end

      [unquote(endian), binary, rest]
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

    def do_encode(%PointZM{coordinates: {x, y, z, m}}, unquote(endian_atom)) do
      {@point_zm,
       [
         <<x::unquote(modifier)-float-64>>,
         <<y::unquote(modifier)-float-64>>,
         <<z::unquote(modifier)-float-64>>,
         <<m::unquote(modifier)-float-64>>
       ]}
    end

    def do_encode(%LineString{coordinates: coordinates}, unquote(endian_atom)) do
      {coordinates, count} =
        Enum.map_reduce(coordinates, 0, fn {x, y}, acc ->
          {[<<x::unquote(modifier)-float-64>>, <<y::unquote(modifier)-float-64>>], acc + 1}
        end)

      {@line_string, [<<count::unquote(modifier)-32>> | coordinates]}
    end

    def do_encode(%LineStringM{coordinates: coordinates}, unquote(endian_atom)) do
      {coordinates, count} =
        Enum.map_reduce(coordinates, 0, fn {x, y, z}, acc ->
          {[
             <<x::unquote(modifier)-float-64>>,
             <<y::unquote(modifier)-float-64>>,
             <<z::unquote(modifier)-float-64>>
           ], acc + 1}
        end)

      {@line_string_m, [<<count::unquote(modifier)-32>> | coordinates]}
    end

    def do_encode(%LineStringZ{coordinates: coordinates}, unquote(endian_atom)) do
      {coordinates, count} =
        Enum.map_reduce(coordinates, 0, fn {x, y, z}, acc ->
          {[
             <<x::unquote(modifier)-float-64>>,
             <<y::unquote(modifier)-float-64>>,
             <<z::unquote(modifier)-float-64>>
           ], acc + 1}
        end)

      {@line_string_z, [<<count::unquote(modifier)-32>> | coordinates]}
    end

    def do_encode(%Polygon{coordinates: coordinates}, unquote(endian_atom)) do
      {coordinates, count} =
        Enum.map_reduce(coordinates, 0, fn ring, acc ->
          {_, data} = do_encode(%LineString{coordinates: ring}, unquote(endian_atom))
          {data, acc + 1}
        end)

      {@polygon, [<<count::unquote(modifier)-32>> | coordinates]}
    end

    def do_encode(%PolygonZ{coordinates: coordinates}, unquote(endian_atom)) do
      {coordinates, count} =
        Enum.map_reduce(coordinates, 0, fn ring, acc ->
          {_, data} = do_encode(%LineStringZ{coordinates: ring}, unquote(endian_atom))
          {data, acc + 1}
        end)

      {@polygon_z, [<<count::unquote(modifier)-32>> | coordinates]}
    end

    def do_encode(%MultiPoint{coordinates: coordinates}, unquote(endian_atom)) do
      {coordinates, count} =
        Enum.map_reduce(coordinates, 0, fn coordinate, acc ->
          point = encode!(%Point{coordinates: coordinate}, unquote(endian_atom))
          {point, acc + 1}
        end)

      {@multi_point, [<<count::unquote(modifier)-32>> | coordinates]}
    end

    def do_encode(%MultiPointM{coordinates: coordinates}, unquote(endian_atom)) do
      {coordinates, count} =
        Enum.map_reduce(coordinates, 0, fn coordinate, acc ->
          point = encode!(%PointM{coordinates: coordinate}, unquote(endian_atom))
          {point, acc + 1}
        end)

      {@multi_point_m, [<<count::unquote(modifier)-32>> | coordinates]}
    end

    def do_encode(%MultiPointZ{coordinates: coordinates}, unquote(endian_atom)) do
      {coordinates, count} =
        Enum.map_reduce(coordinates, 0, fn coordinate, acc ->
          point = encode!(%PointZ{coordinates: coordinate}, unquote(endian_atom))
          {point, acc + 1}
        end)

      {@multi_point_z, [<<count::unquote(modifier)-32>> | coordinates]}
    end

    def do_encode(%MultiLineString{coordinates: coordinates}, unquote(endian_atom)) do
      {coordinates, count} =
        Enum.map_reduce(coordinates, 0, fn coordinate, acc ->
          geom = encode!(%LineString{coordinates: coordinate}, unquote(endian_atom))
          {geom, acc + 1}
        end)

      {@multi_line_string, [<<count::unquote(modifier)-32>> | coordinates]}
    end

    def do_encode(%MultiLineStringZ{coordinates: coordinates}, unquote(endian_atom)) do
      {coordinates, count} =
        Enum.map_reduce(coordinates, 0, fn coordinate, acc ->
          geom = encode!(%LineStringZ{coordinates: coordinate}, unquote(endian_atom))
          {geom, acc + 1}
        end)

      {@multi_line_string_z, [<<count::unquote(modifier)-32>> | coordinates]}
    end

    def do_encode(%MultiPolygon{coordinates: coordinates}, unquote(endian_atom)) do
      {coordinates, count} =
        Enum.map_reduce(coordinates, 0, fn coordinate, acc ->
          geom = encode!(%Polygon{coordinates: coordinate}, unquote(endian_atom))
          {geom, acc + 1}
        end)

      {@multi_polygon, [<<count::unquote(modifier)-32>> | coordinates]}
    end

    def do_encode(%MultiPolygonZ{coordinates: coordinates}, unquote(endian_atom)) do
      {coordinates, count} =
        Enum.map_reduce(coordinates, 0, fn coordinate, acc ->
          geom = encode!(%PolygonZ{coordinates: coordinate}, unquote(endian_atom))
          {geom, acc + 1}
        end)

      {@multi_polygon_z, [<<count::unquote(modifier)-32>> | coordinates]}
    end

    def do_encode(%GeometryCollection{geometries: geometries}, unquote(endian_atom)) do
      {coordinates, count} =
        Enum.map_reduce(geometries, 0, fn geom, acc ->
          geom = encode!(%{geom | srid: nil}, unquote(endian_atom))
          {geom, acc + 1}
        end)

      {@geometry_collection, [<<count::unquote(modifier)-32>> | coordinates]}
    end
  end
end
