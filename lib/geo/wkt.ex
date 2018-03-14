defmodule Geo.WKT do
  @moduledoc """
  Converts to and from WKT and EWKT

      point = Geo.WKT.decode("POINT(30 -90)")
      Geo.Point[coordinates: {30, -90}, srid: nil]

      Geo.WKT.encode(point)
      "POINT(30 -90)"

      point = Geo.WKT.decode("SRID=4326;POINT(30 -90)")
      Geo.Point[coordinates: {30, -90}, srid: 4326]

  """

  alias Geo.WKT.{Encoder, Decoder}

  @doc """
  Takes a Geometry and returns a WKT string
  """
  @spec encode(Geo.geometry()) :: binary
  defdelegate encode(geom), to: Encoder

  @doc """
  Takes a WKT string and returns a Geo.Geometry struct or list of Geo.Geometry
  """
  @spec decode(binary) :: Geo.geometry()
  defdelegate decode(wkt), to: Decoder
end
