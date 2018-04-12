defmodule Geo.GeometryCollection do
  @moduledoc """
  Defines the GeometryCollection struct.
  """

  @type t :: %Geo.GeometryCollection{geometries: [Geo.geometry()], srid: integer}
  defstruct geometries: [], srid: nil
end
