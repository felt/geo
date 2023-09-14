defmodule Geo.PointZ do
  @moduledoc """
  Defines the PointZ struct.
  """

  @type t :: %Geo.PointZ{
          coordinates: {number, number, number},
          srid: integer | nil,
          properties: map
        }
  defstruct coordinates: {0, 0, 0}, srid: nil, properties: %{}
end
