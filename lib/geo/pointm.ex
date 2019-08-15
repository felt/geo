defmodule Geo.PointM do
  @moduledoc """
  Defines the PointM struct.
  """

  @type t :: %Geo.PointM{coordinates: {number, number, number}, srid: integer | nil, properties: map}
  defstruct coordinates: {0, 0, 0}, srid: nil, properties: %{}
end
