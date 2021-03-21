defmodule Geo.WKT do
  @moduledoc """
  Converts to and from WKT and EWKT

  ## Examples

      iex> {:ok, point} = Geo.WKT.decode("POINT(30 -90)")
      Geo.Point[coordinates: {30, -90}, srid: nil]

      iex> Geo.WKT.encode!(point)
      "POINT(30 -90)"

      iex> point = Geo.WKT.decode!("SRID=4326;POINT(30 -90)")
      Geo.Point[coordinates: {30, -90}, srid: 4326]

  """

  alias Geo.WKT.{Encoder, Decoder}

  @doc """
  Takes a Geometry and returns a WKT string.
  """
  @spec encode(Geo.geometry()) :: {:ok, binary} | {:error, Exception.t()}
  defdelegate encode(geom), to: Encoder

  @doc """
  Takes a Geometry and returns a WKT string.
  """
  @spec encode!(Geo.geometry()) :: binary
  defdelegate encode!(geom), to: Encoder

  @doc """
  Takes a WKT string and returns a Geo.geometry struct or list of Geo.geometry.
  """
  @spec decode(binary) :: {:ok, Geo.geometry()} | {:error, Exception.t()}
  defdelegate decode(wkt), to: Decoder

  @doc """
  Takes a WKT string and returns a Geo.geometry struct or list of Geo.geometry.
  """
  @spec decode!(binary) :: Geo.geometry() | no_return
  defdelegate decode!(wkt), to: Decoder
end
