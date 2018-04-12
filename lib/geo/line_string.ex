defmodule Geo.LineString do
  @moduledoc """
  Defines the LineString struct.
  """

  @type t :: %Geo.LineString{coordinates: [{number, number}], srid: integer}
  defstruct coordinates: [], srid: nil
end
