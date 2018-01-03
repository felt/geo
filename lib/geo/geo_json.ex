defmodule Geo.JSON do
  alias Geo.Point
  alias Geo.LineString
  alias Geo.Polygon
  alias Geo.MultiPoint
  alias Geo.MultiLineString
  alias Geo.MultiPolygon
  alias Geo.GeometryCollection

  defmodule DecodeError do
    defexception [:message]
  end

  defmodule EncodeError do
    defexception [:message]
  end

  @moduledoc """
  Converts Geo structs to and from a map representing GeoJSON.


  You are responsible to encoding and decoding of JSON. This is so
  that you can use any JSON parser you want as well as making it
  so that you can use the resulting GeoJSON structure as a property
  in larger JSON structures.

  ```
  #Using Poison as the JSON parser for these examples

  json = "{ \\"type\\": \\"Point\\", \\"coordinates\\": [100.0, 0.0] }"
  geom = Poison.decode!(json) |> Geo.JSON.decode(json)
  Geo.Point[coordinates: {100.0, 0.0}, srid: nil]

  Geo.JSON.encode(geom) |> Poison.encode!
  "{ \\"type\\": \\"Point\\", \\"coordinates\\": [100.0, 0.0] }"

  Geo.JSON.encode(geom)
  %{ "type" => "Point", "coordinates" => [100.0, 0.0] }
  ```
  """

  @doc """
  Takes a map representing GeoJSON and returns a Geometry
  """
  @spec decode(Map.t) :: Geo.geometry
  def decode(geo_json) do
    cond do
      Map.has_key?(geo_json, "geometries") ->
        crs = Map.get(geo_json, "crs")
        geometries = Enum.map(Map.get(geo_json, "geometries"),
        fn(x) ->
          do_decode(Map.get(x, "type"), Map.get(x, "coordinates"), crs)
        end)

        %GeometryCollection{ geometries: geometries }
      Map.has_key?(geo_json, "coordinates") ->
        crs = Map.get(geo_json, "crs")
        do_decode(Map.get(geo_json, "type"), Map.get(geo_json, "coordinates"), crs)
      true ->
        raise DecodeError,
          message: "Unable to decode given value: #{inspect geo_json}"
    end
  end

  defp do_decode("Point", [x, y], crs) do
    %Point{ coordinates: {x, y}, srid: get_srid(crs)}
  end

  defp do_decode("LineString", coordinates, crs) do
    coordinates = Enum.map(coordinates, &List.to_tuple(&1))

    %LineString{ coordinates: coordinates, srid: get_srid(crs) }
  end

  defp do_decode("Polygon", coordinates, crs) do
    coordinates = Enum.map(coordinates, fn(sub_coordinates) ->
      Enum.map(sub_coordinates, &List.to_tuple(&1))
    end)

    %Polygon{ coordinates: coordinates, srid: get_srid(crs) }
  end

  defp do_decode("MultiPoint", coordinates, crs) do
    coordinates = Enum.map(coordinates, &List.to_tuple(&1))

    %MultiPoint{ coordinates: coordinates, srid: get_srid(crs)}
  end

  defp do_decode("MultiLineString", coordinates, crs) do
    coordinates = Enum.map(coordinates, fn(sub_coordinates) ->
      Enum.map(sub_coordinates, &List.to_tuple(&1))
    end)

    %MultiLineString{ coordinates: coordinates, srid: get_srid(crs) }
  end

  defp do_decode("MultiPolygon", coordinates, crs) do
    coordinates = Enum.map(coordinates, fn(sub_coordinates) ->
      Enum.map(sub_coordinates, fn(third_sub_coordinates) ->
        Enum.map(third_sub_coordinates, &List.to_tuple(&1))
      end)
    end)

    %MultiPolygon{ coordinates: coordinates, srid: get_srid(crs) }
  end

  defp get_srid(%{"type" => "name", "properties" => %{ "name" => "EPSG:" <> srid } }) do
    {srid, _} = Integer.parse(srid)
    srid
  end

  # Previous versions of this library incorrectly encoded the name without the
  # colon. This clause allows JSON encoded with those versions to still be
  # decoded.
  defp get_srid(%{"type" => "name", "properties" => %{ "name" => "EPSG" <> srid } }) do
    {srid, _} = Integer.parse(srid)
    srid
  end

  defp get_srid(%{"type" => "name", "properties" => %{ "name" => srid } }) do
    srid
  end

  defp get_srid(nil) do
    nil
  end


  @doc """
  Takes a Geometry and returns a map representing the GeoJSON
  """
  @spec encode(Geo.geometry) :: Map.t
  def encode(geom) do
    case geom do
      %GeometryCollection{ geometries: geometries, srid: srid } ->
        %{ "type" => "GeometryCollection",  "geometries" => Enum.map(geometries, &do_encode(&1))}
        |> add_crs(srid)
      _ ->
        do_encode(geom)
        |> add_crs(geom.srid)
    end
  end

  defp do_encode(%Point{ coordinates: {x, y} }) do
    %{ "type" => "Point", "coordinates" => [x, y] }
  end

  defp do_encode(%LineString{ coordinates: coordinates }) do
    coordinates = Enum.map(coordinates, &Tuple.to_list(&1))

    %{ "type" => "LineString", "coordinates" => coordinates }
  end

  defp do_encode(%Polygon{ coordinates: coordinates }) do
    coordinates = Enum.map(coordinates, fn(sub_coordinates) ->
      Enum.map(sub_coordinates, &Tuple.to_list(&1))
    end)

    %{ "type" => "Polygon", "coordinates" => coordinates }
  end

  defp do_encode(%MultiPoint{ coordinates: coordinates }) do
    coordinates = Enum.map(coordinates, &Tuple.to_list(&1))

    %{ "type" => "MultiPoint", "coordinates" => coordinates }
  end

  defp do_encode(%MultiLineString{ coordinates: coordinates }) do
    coordinates = Enum.map(coordinates, fn(sub_coordinates) ->
      Enum.map(sub_coordinates, &Tuple.to_list(&1))
    end)

    %{ "type" => "MultiLineString", "coordinates" => coordinates }
  end

  defp do_encode(%MultiPolygon{ coordinates: coordinates }) do
    coordinates = Enum.map(coordinates, fn(sub_coordinates) ->
      Enum.map(sub_coordinates, fn(third_sub_coordinates) ->
        Enum.map(third_sub_coordinates, &Tuple.to_list(&1))
      end)
    end)

    %{ "type" => "MultiPolygon", "coordinates" => coordinates }
  end

  defp do_encode(data) do
    raise EncodeError,
      message: "Unable to encode given value: #{inspect data}"
  end

  defp add_crs(map, nil) do
    map
  end

  defp add_crs(map, srid) do
    Map.put(map, "crs", %{"type" => "name", "properties" => %{"name" => "EPSG:#{srid}"}})
  end

end
