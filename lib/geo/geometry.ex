if Code.ensure_loaded?(Ecto.Type) do
  defmodule Geo.Geometry do
    @moduledoc """
    Implements the Ecto.Type behaviour for all geometry types
    """

    alias Geo.Config

    @types [
      "Point",
      "LineString",
      "Polygon",
      "MultiPoint",
      "MultiLineString",
      "MultiPolygon"
    ]

    @behaviour Ecto.Type

    def type, do: :geometry

    def blank?(_), do: false

    def load(%Geo.Point{} = geom), do: {:ok, geom}
    def load(%Geo.LineString{} = geom), do: {:ok, geom}
    def load(%Geo.Polygon{} = geom), do: {:ok, geom}
    def load(%Geo.MultiPoint{} = geom), do: {:ok, geom}
    def load(%Geo.MultiLineString{} = geom), do: {:ok, geom}
    def load(%Geo.MultiPolygon{} = geom), do: {:ok, geom}
    def load(%Geo.GeometryCollection{} = geom), do: {:ok, geom}
    def load(_), do: :error

    def dump(%Geo.Point{} = geom), do: {:ok, geom}
    def dump(%Geo.LineString{} = geom), do: {:ok, geom}
    def dump(%Geo.Polygon{} = geom), do: {:ok, geom}
    def dump(%Geo.MultiPoint{} = geom), do: {:ok, geom}
    def dump(%Geo.MultiLineString{} = geom), do: {:ok, geom}
    def dump(%Geo.MultiPolygon{} = geom), do: {:ok, geom}
    def dump(%Geo.GeometryCollection{} = geom), do: {:ok, geom}
    def dump(_), do: :error

    def cast(%Geo.Point{} = geom), do: {:ok, geom}
    def cast(%Geo.LineString{} = geom), do: {:ok, geom}
    def cast(%Geo.Polygon{} = geom), do: {:ok, geom}
    def cast(%Geo.MultiPoint{} = geom), do: {:ok, geom}
    def cast(%Geo.MultiLineString{} = geom), do: {:ok, geom}
    def cast(%Geo.MultiPolygon{} = geom), do: {:ok, geom}
    def cast(%Geo.GeometryCollection{} = geom), do: {:ok, geom}

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
