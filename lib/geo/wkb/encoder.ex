defmodule Geo.WKB.Encoder do
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
    MultiPoint,
    MultiPointZ,
    MultiLineString,
    MultiLineStringZ,
    MultiPolygon,
    MultiPolygonZ,
    GeometryCollection,
    Utils
  }

  alias Geo.WKB.Writer

  @doc """
  Takes a Geometry and returns a WKB string. The endian decides
  what the byte order will be
  """
  @spec encode(binary, Geo.endian()) :: {:ok, binary} | {:error, Exception.t()}
  def encode(geom, endian \\ :xdr) do
    {:ok, encode!(geom, endian)}
  rescue
    exception ->
      {:error, exception}
  end

  @doc """
  Takes a Geometry and returns a WKB string. The endian decides
  what the byte order will be
  """
  @spec encode!(binary, Geo.endian()) :: binary | no_return
  def encode!(geom, endian \\ :xdr) do
    writer = Writer.new(endian)
    do_encode(geom, writer)
  end

  defp do_encode(%GeometryCollection{} = geom, writer) do
    type =
      Utils.type_to_hex(geom, geom.srid != nil)
      |> Integer.to_string(16)
      |> Utils.pad_left(8)

    srid = if geom.srid, do: Integer.to_string(geom.srid, 16) |> Utils.pad_left(8), else: ""

    count = Integer.to_string(Enum.count(geom.geometries), 16) |> Utils.pad_left(8)

    writer = Writer.write(writer, type)
    writer = Writer.write(writer, srid)
    writer = Writer.write(writer, count)

    coordinates =
      Enum.map(geom.geometries, fn x ->
        x = %{x | srid: nil}
        encode!(x, writer.endian)
      end)

    coordinates = Enum.join(coordinates)

    writer.wkb <> coordinates
  end

  defp do_encode(geom, writer) do
    type =
      Utils.type_to_hex(geom, geom.srid != nil)
      |> Integer.to_string(16)
      |> Utils.pad_left(8)

    srid = if geom.srid, do: Integer.to_string(geom.srid, 16) |> Utils.pad_left(8), else: ""

    writer = Writer.write(writer, type)
    writer = Writer.write(writer, srid)

    writer = encode_coordinates(writer, geom)
    writer.wkb
  end

  defp encode_coordinates(writer, %Point{coordinates: {x, y}}) do
    x = x |> Utils.float_to_hex(64) |> Integer.to_string(16) |> Utils.pad_left(16)
    y = y |> Utils.float_to_hex(64) |> Integer.to_string(16) |> Utils.pad_left(16)

    writer = Writer.write(writer, x)
    Writer.write(writer, y)
  end

  defp encode_coordinates(writer, %PointZ{coordinates: {x, y, z}}) do
    x = x |> Utils.float_to_hex(64) |> Integer.to_string(16) |> Utils.pad_left(16)
    y = y |> Utils.float_to_hex(64) |> Integer.to_string(16) |> Utils.pad_left(16)
    z = z |> Utils.float_to_hex(64) |> Integer.to_string(16) |> Utils.pad_left(16)

    writer
    |> Writer.write(x)
    |> Writer.write(y)
    |> Writer.write(z)
  end

  defp encode_coordinates(writer, %PointM{coordinates: {x, y, m}}) do
    x = x |> Utils.float_to_hex(64) |> Integer.to_string(16) |> Utils.pad_left(16)
    y = y |> Utils.float_to_hex(64) |> Integer.to_string(16) |> Utils.pad_left(16)
    m = m |> Utils.float_to_hex(64) |> Integer.to_string(16) |> Utils.pad_left(16)

    writer
    |> Writer.write(x)
    |> Writer.write(y)
    |> Writer.write(m)
  end

  defp encode_coordinates(writer, %PointZM{coordinates: {x, y, z, m}}) do
    x = x |> Utils.float_to_hex(64) |> Integer.to_string(16) |> Utils.pad_left(16)
    y = y |> Utils.float_to_hex(64) |> Integer.to_string(16) |> Utils.pad_left(16)
    z = z |> Utils.float_to_hex(64) |> Integer.to_string(16) |> Utils.pad_left(16)
    m = m |> Utils.float_to_hex(64) |> Integer.to_string(16) |> Utils.pad_left(16)

    writer
    |> Writer.write(x)
    |> Writer.write(y)
    |> Writer.write(z)
    |> Writer.write(m)
  end

  defp encode_coordinates(writer, %LineString{coordinates: coordinates}) do
    number_of_points = Integer.to_string(length(coordinates), 16) |> Utils.pad_left(8)
    writer = Writer.write(writer, number_of_points)

    {_nils, writer} =
      Enum.map_reduce(coordinates, writer, fn pair, acc ->
        acc = encode_coordinates(acc, %Point{coordinates: pair})
        {nil, acc}
      end)

    writer
  end

  defp encode_coordinates(writer, %LineStringZ{coordinates: coordinates}) do
    number_of_points = Integer.to_string(length(coordinates), 16) |> Utils.pad_left(8)
    writer = Writer.write(writer, number_of_points)

    {_nils, writer} =
      Enum.map_reduce(coordinates, writer, fn point, acc ->
        acc = encode_coordinates(acc, %PointZ{coordinates: point})
        {nil, acc}
      end)

    writer
  end

  defp encode_coordinates(writer, %Polygon{coordinates: coordinates}) do
    number_of_lines = Integer.to_string(length(coordinates), 16) |> Utils.pad_left(8)
    writer = Writer.write(writer, number_of_lines)

    {_nils, writer} =
      Enum.map_reduce(coordinates, writer, fn line, acc ->
        acc = encode_coordinates(acc, %LineString{coordinates: line})
        {nil, acc}
      end)

    writer
  end

  defp encode_coordinates(writer, %PolygonZ{coordinates: coordinates}) do
    number_of_lines = Integer.to_string(length(coordinates), 16) |> Utils.pad_left(8)
    writer = Writer.write(writer, number_of_lines)

    {_nils, writer} =
      Enum.map_reduce(coordinates, writer, fn line, acc ->
        acc = encode_coordinates(acc, %LineStringZ{coordinates: line})
        {nil, acc}
      end)

    writer
  end

  defp encode_coordinates(writer, %MultiPoint{coordinates: coordinates}) do
    writer = Writer.write(writer, Integer.to_string(length(coordinates), 16) |> Utils.pad_left(8))

    geoms =
      Enum.map(coordinates, fn geom ->
        encode!(%Point{coordinates: geom}, writer.endian)
      end)
      |> Enum.join()

    Writer.write_no_endian(writer, geoms)
  end

  defp encode_coordinates(writer, %MultiPointZ{coordinates: coordinates}) do
    writer = Writer.write(writer, Integer.to_string(length(coordinates), 16) |> Utils.pad_left(8))

    geoms =
      Enum.map(coordinates, fn geom ->
        encode!(%PointZ{coordinates: geom}, writer.endian)
      end)
      |> Enum.join()

    Writer.write_no_endian(writer, geoms)
  end

  defp encode_coordinates(writer, %MultiLineString{coordinates: coordinates}) do
    writer = Writer.write(writer, Integer.to_string(length(coordinates), 16) |> Utils.pad_left(8))

    geoms =
      Enum.map(coordinates, fn geom ->
        encode!(%LineString{coordinates: geom}, writer.endian)
      end)
      |> Enum.join()

    Writer.write_no_endian(writer, geoms)
  end

  defp encode_coordinates(writer, %MultiLineStringZ{coordinates: coordinates}) do
    writer = Writer.write(writer, Integer.to_string(length(coordinates), 16) |> Utils.pad_left(8))

    geoms =
      Enum.map(coordinates, fn geom ->
        encode!(%LineStringZ{coordinates: geom}, writer.endian)
      end)
      |> Enum.join()

    Writer.write_no_endian(writer, geoms)
  end

  defp encode_coordinates(writer, %MultiPolygon{coordinates: coordinates}) do
    writer = Writer.write(writer, Integer.to_string(length(coordinates), 16) |> Utils.pad_left(8))

    geoms =
      Enum.map(coordinates, fn geom ->
        encode!(%Polygon{coordinates: geom}, writer.endian)
      end)
      |> Enum.join()

    Writer.write_no_endian(writer, geoms)
  end

  defp encode_coordinates(writer, %MultiPolygonZ{coordinates: coordinates}) do
    writer = Writer.write(writer, Integer.to_string(length(coordinates), 16) |> Utils.pad_left(8))

    geoms =
      Enum.map(coordinates, fn geom ->
        encode!(%PolygonZ{coordinates: geom}, writer.endian)
      end)
      |> Enum.join()

    Writer.write_no_endian(writer, geoms)
  end
end
