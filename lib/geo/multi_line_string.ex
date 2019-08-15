defmodule Geo.MultiLineString do
  @moduledoc """
  Defines the MultiLineString struct.
  """

  @type t :: %Geo.MultiLineString{
          coordinates: [[{number, number}]],
          srid: integer | nil,
          properties: map
        }
  defstruct coordinates: [], srid: nil, properties: %{}
end
