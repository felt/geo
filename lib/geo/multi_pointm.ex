defmodule Geo.MultiPointM do
  @moduledoc """
  Defines the MultiPointZ struct.
  """

  @type t :: %__MODULE__{coordinates: [{number, number, number}], srid: integer | nil, properties: map}
  defstruct coordinates: [], srid: nil, properties: %{}
end
