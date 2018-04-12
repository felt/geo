defmodule Geo.Point do
  @moduledoc """
  Defines the Point struct.
  """

  @type t :: %Geo.Point{coordinates: {number, number}, srid: integer}
  defstruct coordinates: {0, 0}, srid: nil
end
