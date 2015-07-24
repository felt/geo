defmodule Geo.JSON do
  alias Geo.Point
  alias Geo.LineString
  alias Geo.Polygon
  alias Geo.MultiPoint
  alias Geo.MultiLineString
  alias Geo.MultiPolygon
  alias Geo.GeometryCollection

  @moduledoc """
  Converts to and from GeoJSON
  
  ```
  json = "{ \"type\": \"Point\", \"coordinates\": [100.0, 0.0] }"
  geom = Geo.JSON.decode(json)
  Geo.Point[coordinates: {100.0, 0.0}, srid: nil]

  Geo.JSON.encode(geom)
  "{ \"type\": \"Point\", \"coordinates\": [100.0, 0.0] }"
  ```
  """

  @doc """
  Takes a GeoJSON string or map and returns a Geometry
  """
  @spec decode(binary) :: Geo.geometry
  def decode(geo_json) when is_binary(geo_json) do
    decoded_json = json_decode(geo_json)
    decode(decoded_json)
  end

  @spec decode(Map.t) :: Geo.geometry
  def decode(geo_json) when is_map(geo_json) do
    crs = Dict.get(geo_json, "crs")
    case Dict.has_key?(geo_json, "geometries") do
      true ->
        geometries = Enum.map(Dict.get(geo_json, "geometries"), 
          fn(x) -> 
            do_decode(Dict.get(x, "type"), Dict.get(x, "coordinates"), crs)
          end)

        %GeometryCollection{ geometries: geometries }
      false ->
        do_decode(Dict.get(geo_json, "type"), Dict.get(geo_json, "coordinates"), crs)
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


  @doc """
  Takes a Geometry and returns a geoJSON string
  """
  @spec encode(Geo.geometry) :: binary
  def encode(%GeometryCollection{ geometries: geometries, srid: srid }) do
    %{ type: "GeometryCollection",  geometries: Enum.map(geometries, &do_encode(&1))} 
    |> add_crs(srid)
    |> json_encode
  end

  def encode(geom) do
    do_encode(geom)
    |> add_crs(geom.srid)
    |> json_encode
  end

  defp do_encode(%Point{ coordinates: {x, y} }) do
    %{ type: "Point", coordinates: [x, y] }
  end

  defp do_encode(%LineString{ coordinates: coordinates }) do
    coordinates = Enum.map(coordinates, &Tuple.to_list(&1))

    %{ type: "LineString", coordinates: coordinates }
  end

  defp do_encode(%Polygon{ coordinates: coordinates }) do
    coordinates = Enum.map(coordinates, fn(sub_coordinates) -> 
      Enum.map(sub_coordinates, &Tuple.to_list(&1))
    end)

    %{ type: "Polygon", coordinates: coordinates }
  end

  defp do_encode(%MultiPoint{ coordinates: coordinates }) do
    coordinates = Enum.map(coordinates, &Tuple.to_list(&1))

    %{ type: "MultiPoint", coordinates: coordinates }
  end

  defp do_encode(%MultiLineString{ coordinates: coordinates }) do
    coordinates = Enum.map(coordinates, fn(sub_coordinates) -> 
      Enum.map(sub_coordinates, &Tuple.to_list(&1))
    end)

    %{ type: "MultiLineString", coordinates: coordinates }
  end

  defp do_encode(%MultiPolygon{ coordinates: coordinates }) do
    coordinates = Enum.map(coordinates, fn(sub_coordinates) -> 
      Enum.map(sub_coordinates, fn(third_sub_coordinates) -> 
        Enum.map(third_sub_coordinates, &Tuple.to_list(&1))
      end)
    end)

    %{ type: "MultiPolygon", coordinates: coordinates }
  end

  defp add_crs(map, nil) do
    map
  end

  defp add_crs(map, srid) do
    Dict.put(map, :crs, %{type: "name", properties: %{name: "EPSG#{srid}"}})
  end


  defp json_encode(data) do
    Poison.encode!(data)
  end

  defp json_decode(json) do
    Poison.decode!(json)
  end

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

end
