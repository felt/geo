defmodule Geo.LineString do
  @moduledoc """
  Defines the LineString struct.
  """

  @type t :: %Geo.LineString{
          coordinates: [{number, number}],
          srid: integer | nil,
          properties: map
        }
  defstruct coordinates: [], srid: nil, properties: %{}
end
