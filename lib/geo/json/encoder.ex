defmodule Geo.JSON.Encoder do
  @moduledoc false

  alias Geo.{
    Point,
    LineString,
    Polygon,
    MultiPoint,
    MultiLineString,
    MultiPolygon,
    GeometryCollection
  }

  defmodule EncodeError do
    @type t :: %__MODULE__{message: String.t(), value: any}

    defexception [:message, :value]

    def message(%{message: nil, value: value}) do
      "unable to encode value: #{inspect(value)}"
    end

    def message(%{message: message}) do
      message
    end
  end

  @doc """
  Takes a Geometry and returns a map representing the GeoJSON
  """
  @spec encode!(Geo.geometry()) :: Map.t()
  def encode!(geom) do
    case geom do
      %GeometryCollection{geometries: geometries, srid: srid} ->
        %{"type" => "GeometryCollection", "geometries" => Enum.map(geometries, &do_encode(&1))}
        |> add_crs(srid)

      _ ->
        do_encode(geom)
        |> add_crs(geom.srid)
    end
  end

  @doc """
  Takes a Geometry and returns a map representing the GeoJSON
  """
  @spec encode(Geo.geometry()) :: {:ok, Map.t()} | {:error, EncodeError.t()}
  def encode(geom) do
    {:ok, encode!(geom)}
  rescue
    exception in [EncodeError] ->
      {:error, exception}
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
