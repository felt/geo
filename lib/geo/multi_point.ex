defmodule Geo.MultiPoint do
  @moduledoc """
  Defines the MultiPoint struct.
  """

  @type t :: %Geo.MultiPoint{coordinates: [{number, number}], srid: integer}
  defstruct coordinates: [], srid: nil
end
