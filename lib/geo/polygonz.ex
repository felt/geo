defmodule Geo.PolygonZ do
  @moduledoc """
  Defines the Polygon struct.
  """

  @type t :: %__MODULE__{
          coordinates: [[{number, number, number}]],
          srid: integer | nil,
          properties: map
        }
  defstruct coordinates: [], srid: nil, properties: %{}
end
