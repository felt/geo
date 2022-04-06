defmodule Geo.LineStringZM do
  @moduledoc """
  Defines the LineStringZM struct.
  """

  @type t :: %__MODULE__{coordinates: [{number, number, number, number}], srid: integer | nil, properties: map}
  defstruct coordinates: [], srid: nil, properties: %{}
end
