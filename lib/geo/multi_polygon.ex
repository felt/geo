defmodule Geo.MultiPolygon do
  @moduledoc """
  Defines the MultiPolygon struct.
  """

  @type t :: %Geo.MultiPolygon{coordinates: [[[{number, number}]]], srid: integer}
  defstruct coordinates: [], srid: nil
end
