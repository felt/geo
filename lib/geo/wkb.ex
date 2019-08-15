defmodule Geo.WKB do
  @moduledoc """
  Converts to and from WKB and EWKB

      {:ok, point} = Geo.WKB.decode("0101000000000000000000F03F000000000000F03F")
      Geo.Point[coordinates: {1, 1}, srid: nil]

      Geo.WKT.encode!(point)
      "POINT(1 1)"

      point = Geo.WKB.decode!("0101000020E61000009EFB613A637B4240CF2C0950D3735EC0")
      Geo.Point[coordinates: {36.9639657, -121.8097725}, srid: 4326]
  """

  alias Geo.WKB.{Encoder, Decoder}

  @doc """
  Takes a Geometry and returns a WKB string. The endian decides
  what the byte order will be
  """
  @spec encode!(Geo.geometry(), Geo.endian()) :: binary | no_return
  defdelegate encode!(geom, endian \\ :xdr), to: Encoder

  @doc """
  Takes a Geometry and returns a WKB string. The endian decides
  what the byte order will be
  """
  @spec encode(binary, Geo.endian()) :: {:ok, binary} | {:error, Exception.t()}
  defdelegate encode(geom, endian \\ :xdr), to: Encoder

  @doc """
  Takes a WKB string and returns a Geometry
  """
  @spec decode(binary, [Geo.geometry()]) :: {:ok, Geo.geometry()} | {:error, Exception.t()}
  defdelegate decode(wkb, geometries \\ []), to: Decoder

  @doc """
  Takes a WKB string and returns a Geometry
  """
  @spec decode!(binary, [Geo.geometry()]) :: Geo.geometry() | no_return
  defdelegate decode!(wkb, geometries \\ []), to: Decoder
end
