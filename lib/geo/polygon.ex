defmodule Geo.Polygon do

  @moduledoc """
  Defines the Polygon struct. Implements the Ecto.Type behaviour
  """

  @type t :: %Geo.Polygon{ coordinates: [[{number, number}]], srid: integer }
  @behaviour Ecto.Type
  defstruct coordinates: [], srid: nil

  def type, do: :geometry

  def blank?(_), do: false

  def load(%Geo.Polygon{} = polygon), do: {:ok, polygon}
  def load(_), do: :error

  def dump(%Geo.Polygon{} = polygon), do: {:ok, polygon}
  def dump(_), do: :error

  def cast(%Geo.Polygon{} = polygon), do: {:ok, polygon}
  def cast(_), do: :error

end