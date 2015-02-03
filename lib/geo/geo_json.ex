defmodule Geo.JSON do
  alias Geo.Point
  alias Geo.LineString
  alias Geo.Polygon
  alias Geo.MultiPoint
  alias Geo.MultiLineString
  alias Geo.MultiPolygon
  alias Geo.GeometryCollection
  use Jazz

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
  Takes a GeoJSON string and returns a Geometry
  """
  @spec decode(binary) :: Geo.geometry
  def decode(geo_json) do
    decoded_json = JSON.decode!(geo_json, keys: :atoms)

    case Map.has_key?(decoded_json, :geometries) do
      true ->
        geometries = Enum.map(decoded_json.geometries, 
          fn(x) -> do_decode(x.type, x.coordinates)   end)

        %GeometryCollection{ geometries: geometries }
      false ->
        do_decode(decoded_json.type, decoded_json.coordinates)
    end 
  end

  defp do_decode("Point", [x, y]) do
    %Point{ coordinates: {x, y}}
  end

  defp do_decode("LineString", coordinates) do
    coordinates = Enum.map(coordinates, &List.to_tuple(&1))

    %LineString{ coordinates: coordinates }
  end

  defp do_decode("Polygon", coordinates) do
    coordinates = Enum.map(coordinates, fn(sub_coordinates) -> 
      Enum.map(sub_coordinates, &List.to_tuple(&1))
    end)

    %Polygon{ coordinates: coordinates }
  end

  defp do_decode("MultiPoint", coordinates) do
    coordinates = Enum.map(coordinates, &List.to_tuple(&1))

    %MultiPoint{ coordinates: coordinates }
  end

  defp do_decode("MultiLineString", coordinates) do
    coordinates = Enum.map(coordinates, fn(sub_coordinates) -> 
      Enum.map(sub_coordinates, &List.to_tuple(&1))
    end)

    %MultiLineString{ coordinates: coordinates }
  end

  defp do_decode("MultiPolygon", coordinates) do
    coordinates = Enum.map(coordinates, fn(sub_coordinates) -> 
      Enum.map(sub_coordinates, fn(third_sub_coordinates) -> 
        Enum.map(third_sub_coordinates, &List.to_tuple(&1))
      end)
    end)

    %MultiPolygon{ coordinates: coordinates }
  end


  @doc """
  Takes a Geometry and returns a geoJSON string
  """
  @spec encode(Geo.geometry) :: binary
  def encode(%GeometryCollection{ geometries: geometries, srid: srid }) do
    %{ type: "GeometryCollection",  geometries: Enum.map(geometries, &do_encode(&1))} 
    |> add_crs(srid)
    |> JSON.encode!
  end

  def encode(geom) do
    do_encode(geom)
    |> add_crs(geom.srid)
    |> JSON.encode!
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
    Map.put(map, :crs, %{type: "name", properties: %{name: "EPSG#{srid}"}})
  end

end
