defmodule Geo.Point do
  @moduledoc """
  Defines the Point struct.
  """

  @type t :: %Geo.Point{coordinates: {number, number}, srid: integer | nil, properties: map}
  defstruct coordinates: {0, 0}, srid: nil, properties: %{}
end
