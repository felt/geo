defmodule Geo.GeometryCollection do

  @moduledoc """
  Defines the GeometryCollection struct. Implements the Ecto.Type behaviour
  """

  @type t :: %Geo.GeometryCollection{ geometries: [Geo.geometry], srid: integer }
  @behaviour Ecto.Type
  defstruct geometries: [], srid: nil

  def type, do: :geometry

  def blank?(_), do: false

  def load(%Geo.GeometryCollection{} = geometry_collection), do: {:ok, geometry_collection}
  def load(_), do: :error

  def dump(%Geo.GeometryCollection{} = geometry_collection), do: {:ok, geometry_collection}
  def dump(_), do: :error

  def cast(%Geo.GeometryCollection{} = geometry_collection), do: {:ok, geometry_collection}
  def cast(geometry_collection) when is_map(geometry_collection), do: { :ok, Geo.JSON.decode(geometry_collection) }
  def cast(geometry_collection) when is_binary(geometry_collection), do: { :ok, Geo.JSON.decode(geometry_collection) }
  def cast(_), do: :error

end