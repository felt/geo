defmodule Geo.PointZM do
  @moduledoc """
  Defines the PointZM struct.
  """

  @type t :: %Geo.PointZM{
          coordinates: {number, number, number, number},
          srid: integer,
          properties: map
        }
  defstruct coordinates: {0, 0, 0, 0}, srid: nil, properties: %{}
end
