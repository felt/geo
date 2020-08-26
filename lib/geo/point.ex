defmodule Geo.Point do
  @moduledoc """
  Defines the Point struct.
  """

  @type latitude :: float
  @type longitude :: float

  @type t :: %Geo.Point{coordinates: {longitude, latitude}, srid: integer | nil, properties: map}
  defstruct coordinates: {0, 0}, srid: nil, properties: %{}
end
