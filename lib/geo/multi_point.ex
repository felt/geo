defmodule Geo.MultiPoint do
  @moduledoc """
  Defines the MultiPoint struct.
  """

  @type t :: %Geo.MultiPoint{coordinates: [{number, number}], srid: integer | nil, properties: map}
  defstruct coordinates: [], srid: nil, properties: %{}
end
