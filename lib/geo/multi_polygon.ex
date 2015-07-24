defmodule Geo.MultiPolygon do

  @moduledoc """
  Defines the MultiPolygon struct. Implements the Ecto.Type behaviour
  """

  @type t :: %Geo.MultiPolygon{ coordinates: [[[{number, number}]]], srid: integer }
  @behaviour Ecto.Type
  defstruct coordinates: [], srid: nil

  def type, do: :geometry

  def blank?(_), do: false

  def load(%Geo.MultiPolygon{} = multi_polygon), do: {:ok, multi_polygon}
  def load(_), do: :error

  def dump(%Geo.MultiPolygon{} = multi_polygon), do: {:ok, multi_polygon}
  def dump(_), do: :error

  def cast(%Geo.MultiPolygon{} = multi_polygon), do: {:ok, multi_polygon}
  def cast(multi_polygon) when is_map(multi_polygon), do: { :ok, Geo.JSON.decode(multi_polygon) }
  def cast(multi_polygon) when is_binary(multi_polygon), do: { :ok, Geo.JSON.decode(multi_polygon) }
  def cast(_), do: :error

end