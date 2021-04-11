defmodule Geo.WKB do
  @moduledoc """
  Converts to and from WKB and EWKB.

  ## Examples

      iex> {:ok, point} = Geo.WKB.decode("0101000000000000000000F03F000000000000F03F")
      Geo.Point[coordinates: {1, 1}, srid: nil]

      iex> Geo.WKT.encode!(point)
      "POINT(1 1)"

      iex> point = Geo.WKB.decode!("0101000020E61000009EFB613A637B4240CF2C0950D3735EC0")
      Geo.Point[coordinates: {36.9639657, -121.8097725}, srid: 4326]

  """

  alias Geo.WKB.{Encoder, Decoder}

  @doc """
  Takes a Geometry and returns a WKB string. The endian decides
  what the byte order will be.
  """
  @spec encode!(Geo.geometry(), Geo.endian()) :: binary
  def encode!(geom, endian \\ :xdr) do
    geom |> Encoder.encode!(endian) |> IO.iodata_to_binary() |> Base.encode16()
  end

  @doc """
  Takes a Geometry and returns a WKB string.

  The endian decides what the byte order will be.
  """
  @spec encode(binary, Geo.endian()) :: {:ok, binary} | {:error, Exception.t()}
  def encode(geom, endian \\ :xdr) do
    {:ok, encode!(geom, endian)}
  rescue
    exception ->
      {:error, exception}
  end

  @doc """
  Takes a Geometry and returns a WKB as iodata.

  The endian decides what the byte order will be.
  """
  @spec encode_to_iodata(Geo.geometry(), Geo.endian()) :: iodata()
  def encode_to_iodata(geom, endian \\ :xdr) do
    Encoder.encode!(geom, endian)
  end

  @doc """
  Takes a WKB string and returns a Geometry.
  """
  @spec decode(binary) :: {:ok, Geo.geometry()} | {:error, Exception.t()}
  def decode(wkb) do
    {:ok, decode!(wkb)}
  rescue
    exception ->
      {:error, exception}
  end

  @doc """
  Takes a WKB string and returns a Geometry.
  """
  @spec decode!(iodata()) :: Geo.geometry()
  def decode!(wkb)

  def decode!("00" <> _ = wkb) do
    wkb
    |> Base.decode16!()
    |> decode!()
  end

  def decode!("01" <> _ = wkb) do
    wkb
    |> Base.decode16!()
    |> decode!()
  end

  def decode!(wkb) do
    Decoder.decode(wkb) |> elem(0)
  end
end
