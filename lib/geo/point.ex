defmodule Geo.Point do

  @moduledoc """
  Defines the Point struct. Implements the Ecto.Type behaviour
  """

  @type t :: %Geo.Point{ coordinates: {number, number}, srid: integer }
  @behaviour Ecto.Type
  defstruct coordinates: {0, 0}, srid: nil

  def type, do: :geometry

  def blank?(_), do: false

  def load(%Geo.Point{} = point), do: {:ok, point}
  def load(_), do: :error

  def dump(%Geo.Point{} = point), do: {:ok, point}
  def dump(_), do: :error

  def cast(%Geo.Point{} = point), do: {:ok, point}
  def cast(_), do: :error

end