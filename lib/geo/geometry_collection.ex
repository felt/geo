defmodule Geo.GeometryCollection do

  @moduledoc """
  Defines the GeometryCollection struct. Implements the Ecto.Type behaviour
  """

  @type t :: %Geo.GeometryCollection{ geometries: [Geo.geometry], srid: integer }
  defstruct geometries: [], srid: nil

  if Code.ensure_loaded?(Ecto.Type) do
    @behaviour Ecto.Type

    def type, do: :geometry

    def blank?(_), do: false

    def load(%Geo.GeometryCollection{} = geometry_collection), do: {:ok, geometry_collection}
    def load(_), do: :error

    def dump(%Geo.GeometryCollection{} = geometry_collection), do: {:ok, geometry_collection}
    def dump(_), do: :error

    def cast(%Geo.GeometryCollection{} = geometry_collection), do: {:ok, geometry_collection}
    def cast(%{"type" => _, "geometries" => _} = geometry_collection), do: { :ok, Geo.JSON.decode(geometry_collection) }

    if Code.ensure_loaded?(Poison) do
      def cast(geometry_collection) when is_binary(geometry_collection), do: { :ok, Poison.decode!(geometry_collection) |> Geo.JSON.decode }
    end

    def cast(_), do: :error
  end

end
