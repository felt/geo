defmodule Geo.LineString do

  @moduledoc """
  Defines the LineString struct. Implements the Ecto.Type behaviour
  """

  @type t :: %Geo.LineString{ coordinates: [{number, number}], srid: integer }
  @behaviour Ecto.Type
  defstruct coordinates: [], srid: nil

  def type, do: :geometry

  def blank?(_), do: false

  def load(%Geo.LineString{} = line_string), do: {:ok, line_string}
  def load(_), do: :error

  def dump(%Geo.LineString{} = line_string), do: {:ok, line_string}
  def dump(_), do: :error

  def cast(%Geo.LineString{} = line_string), do: {:ok, line_string}
  def cast(_), do: :error

end