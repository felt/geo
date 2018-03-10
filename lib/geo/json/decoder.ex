defmodule Geo.JSON.Decoder do
  alias Geo.{
    Point,
    LineString,
    Polygon,
    MultiPoint,
    MultiLineString,
    MultiPolygon,
    GeometryCollection
  }

  defmodule DecodeError do
    @type t :: %__MODULE__{message: String.t, value: any}

    defexception [:message, :value]

      def message(%{message: nil, value: value}) do
      "unable to decode value: #{inspect(value)}"
    end

    def message(%{message: message}) do
      message
    end
  end

  @doc """
  Takes a map representing GeoJSON and returns a Geometry
  """
  @spec decode!(Map.t()) :: Geo.geometry() | no_return
  def decode!(geo_json) do
    cond do
      Map.has_key?(geo_json, "geometries") ->
        crs = Map.get(geo_json, "crs")

        geometries =
          Enum.map(Map.get(geo_json, "geometries"), fn x ->
            do_decode(Map.get(x, "type"), Map.get(x, "coordinates"), crs)
          end)

        %GeometryCollection{geometries: geometries}

      Map.has_key?(geo_json, "coordinates") ->
        crs = Map.get(geo_json, "crs")
        do_decode(Map.get(geo_json, "type"), Map.get(geo_json, "coordinates"), crs)

      true ->
        raise DecodeError, value: geo_json
    end
  end

  @doc """
  Takes a map representing GeoJSON and returns a Geometry
  """
  @spec decode(Map.t()) :: {:ok, Geo.geometry()} | {:error, DecodeError.t()}
  def decode(geo_json) do
    {:ok, decode!(geo_json)}
  rescue
    exception in [DecodeError] ->
      {:error, exception}
  end

  defp do_decode("Point", [x, y], crs) do
    %Point{coordinates: {x, y}, srid: get_srid(crs)}
  end

  defp do_decode("LineString", coordinates, crs) do
    coordinates = Enum.map(coordinates, &List.to_tuple(&1))

    %LineString{coordinates: coordinates, srid: get_srid(crs)}
  end

  defp do_decode("Polygon", coordinates, crs) do
    coordinates =
      Enum.map(coordinates, fn sub_coordinates ->
        Enum.map(sub_coordinates, &List.to_tuple(&1))
      end)

    %Polygon{coordinates: coordinates, srid: get_srid(crs)}
  end

  defp do_decode("MultiPoint", coordinates, crs) do
    coordinates = Enum.map(coordinates, &List.to_tuple(&1))

    %MultiPoint{coordinates: coordinates, srid: get_srid(crs)}
  end

  defp do_decode("MultiLineString", coordinates, crs) do
    coordinates =
      Enum.map(coordinates, fn sub_coordinates ->
        Enum.map(sub_coordinates, &List.to_tuple(&1))
      end)

    %MultiLineString{coordinates: coordinates, srid: get_srid(crs)}
  end

  defp do_decode("MultiPolygon", coordinates, crs) do
    coordinates =
      Enum.map(coordinates, fn sub_coordinates ->
        Enum.map(sub_coordinates, fn third_sub_coordinates ->
          Enum.map(third_sub_coordinates, &List.to_tuple(&1))
        end)
      end)

    %MultiPolygon{coordinates: coordinates, srid: get_srid(crs)}
  end

  defp do_decode(type, _, _) do
    raise DecodeError, message: "#{type} is not a valid"
  end

  defp get_srid(%{"type" => "name", "properties" => %{"name" => "EPSG:" <> srid}}) do
    {srid, _} = Integer.parse(srid)
    srid
  end

  # Previous versions of this library incorrectly encoded the name without the
  # colon. This clause allows JSON encoded with those versions to still be
  # decoded.
  defp get_srid(%{"type" => "name", "properties" => %{"name" => "EPSG" <> srid}}) do
    {srid, _} = Integer.parse(srid)
    srid
  end

  defp get_srid(%{"type" => "name", "properties" => %{"name" => srid}}) do
    srid
  end

  defp get_srid(nil) do
    nil
  end
end
