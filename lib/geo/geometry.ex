if Code.ensure_loaded?(Ecto.Type) do
  defmodule Geo.Geometry do
    @moduledoc """
    Implements the Ecto.Type behaviour for all geometry types
    """

    alias Geo.{
      Config,
      Point,
      PointZ,
      PointM,
      PointZM,
      LineString,
      Polygon,
      MultiPoint,
      MultiLineString,
      MultiPolygon,
      GeometryCollection
    }

    @types [
      "Point",
      "LineString",
      "Polygon",
      "MultiPoint",
      "MultiLineString",
      "MultiPolygon"
    ]

    @geometries [
      Point,
      PointZ,
      PointM,
      PointZM,
      LineString,
      Polygon,
      MultiPoint,
      MultiLineString,
      MultiPolygon,
      GeometryCollection
    ]

    @behaviour Ecto.Type

    def type, do: :geometry

    def blank?(_), do: false

    def load(%struct{} = geom) when struct in @geometries, do: {:ok, geom}
    def load(_), do: :error

    def dump(%struct{} = geom) when struct in @geometries, do: {:ok, geom}
    def dump(_), do: :error

    def cast(%struct{} = geom) when struct in @geometries, do: {:ok, geom}

    def cast(%{"type" => type, "coordinates" => _} = geom) when type in @types do
      {:ok, Geo.JSON.decode(geom)}
    end

    def cast(%{"type" => "GeometryCollection", "geometries" => _} = geom) do
      {:ok, Geo.JSON.decode(geom)}
    end

    def cast(geom) when is_binary(geom) do
      {:ok, Config.json_library().decode!(geom) |> Geo.JSON.decode()}
    end

    def cast(_), do: :error
  end
end
