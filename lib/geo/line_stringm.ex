defmodule Geo.LineStringM do
  @moduledoc """
  Defines the LineStringZ struct.
  """

  @type t :: %__MODULE__{coordinates: [{number, number, number}], srid: integer | nil, properties: map}
  defstruct coordinates: [], srid: nil, properties: %{}
end
