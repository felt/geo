defmodule Geo.Polygon do
  @moduledoc """
  Defines the Polygon struct.
  """

  @type t :: %Geo.Polygon{coordinates: [[{number, number}]], srid: integer, properties: map}
  defstruct coordinates: [], srid: nil, properties: %{}
end
