defmodule Geo.PointZ do
  @moduledoc """
  Defines the PointZ struct.
  """

  @type t :: %Geo.PointZ{coordinates: {number, number, number}, srid: integer}
  defstruct coordinates: {0, 0, 0}, srid: nil
end
