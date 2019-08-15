defmodule Geo.GeometryCollection do
  @moduledoc """
  Defines the GeometryCollection struct.
  """

  @type t :: %Geo.GeometryCollection{geometries: [Geo.geometry()], srid: integer | nil, properties: map}
  defstruct geometries: [], srid: nil, properties: %{}
end
