defmodule Geo.JSON do
  alias Geo.Point
  alias Geo.LineString
  alias Geo.Polygon
  alias Geo.MultiPoint
  alias Geo.MultiLineString
  alias Geo.MultiPolygon
  alias Geo.GeometryCollection

  alias Geo.JSON.{
    Decoder
  }

  defmodule EncodeError do
    @type t :: %EncodeError{message: String.t, value: any}

    defexception [:message, :value]

    def message(%{message: nil, value: value}) do
      "unable to encode value: #{inspect(value)}"
    end

    def message(%{message: message}) do
      message
    end
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
  geom = Poison.decode!(json) |> Geo.JSON.decode!(json)
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
  @spec decode!(Map.t()) :: Geo.geometry() | no_return
  defdelegate decode!(geo_json), to: Decoder

  @doc """
  Takes a map representing GeoJSON and returns a Geometry
  """
  @spec decode(Map.t()) :: {:ok, Geo.geometry()} | {:error, Decoder.DecodeError.t()}
  defdelegate decode(geo_json), to: Decoder

  @doc """
  Takes a Geometry and returns a map representing the GeoJSON
  """
  @spec encode(Geo.geometry()) :: Map.t()
  def encode(geom) do
    case geom do
      %GeometryCollection{geometries: geometries, srid: srid} ->
        %{"type" => "GeometryCollection", "geometries" => Enum.map(geometries, &do_encode(&1))}
        |> add_crs(srid)

      _ ->
        do_encode(geom)
        |> add_crs(geom.srid)
    end
  end

  defp do_encode(%Point{coordinates: {x, y}}) do
    %{"type" => "Point", "coordinates" => [x, y]}
  end

  defp do_encode(%LineString{coordinates: coordinates}) do
    coordinates = Enum.map(coordinates, &Tuple.to_list(&1))

    %{"type" => "LineString", "coordinates" => coordinates}
  end

  defp do_encode(%Polygon{coordinates: coordinates}) do
    coordinates =
      Enum.map(coordinates, fn sub_coordinates ->
        Enum.map(sub_coordinates, &Tuple.to_list(&1))
      end)

    %{"type" => "Polygon", "coordinates" => coordinates}
  end

  defp do_encode(%MultiPoint{coordinates: coordinates}) do
    coordinates = Enum.map(coordinates, &Tuple.to_list(&1))

    %{"type" => "MultiPoint", "coordinates" => coordinates}
  end

  defp do_encode(%MultiLineString{coordinates: coordinates}) do
    coordinates =
      Enum.map(coordinates, fn sub_coordinates ->
        Enum.map(sub_coordinates, &Tuple.to_list(&1))
      end)

    %{"type" => "MultiLineString", "coordinates" => coordinates}
  end

  defp do_encode(%MultiPolygon{coordinates: coordinates}) do
    coordinates =
      Enum.map(coordinates, fn sub_coordinates ->
        Enum.map(sub_coordinates, fn third_sub_coordinates ->
          Enum.map(third_sub_coordinates, &Tuple.to_list(&1))
        end)
      end)

    %{"type" => "MultiPolygon", "coordinates" => coordinates}
  end

  defp do_encode(data) do
    raise EncodeError, message: "Unable to encode given value: #{inspect(data)}"
  end

  defp add_crs(map, nil) do
    map
  end

  defp add_crs(map, srid) do
    Map.put(map, "crs", %{"type" => "name", "properties" => %{"name" => "EPSG:#{srid}"}})
  end
end
