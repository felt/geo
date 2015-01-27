defmodule Geo.Geometry do
  @moduledoc """
  Defines the Geometry struct. Implements the Ecto.Type behaviour
  """

  @type t :: %Geo.Geometry{ type: Geo.type, coordinates: [number], srid: integer }
  @behaviour Ecto.Type
  defstruct type: :geometry, coordinates: [], srid: nil

  def type, do: :geometry

  def blank?, do: false

  def load(%Geo.Geometry{} = geo), do: {:ok, geo}
  def load(_), do: :error

  def dump(%Geo.Geometry{} = geo), do: {:ok, geo}
  def dump(_), do: :error

  def cast(%Geo.Geometry{} = geo), do: {:ok, geo}
  def cast(_), do: :error
end