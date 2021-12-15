defmodule Geo.WKB do
  @moduledoc """
  Converts to and from WKB and EWKB.

  ## Examples

      iex> Geo.WKB.decode!(<<0, 0, 0, 0, 1, 63, 240, 0, 0, 0, 0, 0, 0, 63, 240, 0, 0, 0, 0, 0, 0>>)
      %Geo.Point{coordinates: {1.0, 1.0}, srid: nil}

      iex> Geo.WKB.decode!(<<0, 32, 0, 0, 1, 0, 0, 16, 230, 64, 66, 123, 99, 58, 97, 251, 158, 192, 94, 115, 211, 80, 9, 44, 207>>)
      %Geo.Point{coordinates: {36.9639657, -121.8097725}, srid: 4326}

  """

  alias Geo.WKB.{Encoder, Decoder}

  @deprecated "Use encode_to_iodata/2 instead"
  def encode!(geom, endian \\ :xdr) do
    geom |> Encoder.encode!(endian) |> IO.iodata_to_binary() |> Base.encode16()
  end

  @deprecated "Use encode_to_iodata/2 instead"
  def encode(geom, endian \\ :xdr) do
    {:ok, encode!(geom, endian)}
  rescue
    exception ->
      {:error, exception}
  end

  @doc """
  Takes a Geometry and returns WKB as iodata (a sequence of bytes).

  The endian decides what the byte order will be.
  """
  @spec encode_to_iodata(Geo.geometry(), Geo.endian()) :: iodata()
  def encode_to_iodata(geom, endian \\ :xdr) do
    Encoder.encode!(geom, endian)
  end

  @doc """
  Takes a WKB and returns a Geometry.
  """
  @spec decode(binary) :: {:ok, Geo.geometry()} | {:error, Exception.t()}
  def decode(wkb) do
    {:ok, decode!(wkb)}
  rescue
    exception ->
      {:error, exception}
  end

  @doc """
  Takes a WKB, either as a base-16 encoded string or a binary, and returns a Geometry.
  """
  @spec decode!(binary) :: Geo.geometry()
  def decode!(wkb)

  def decode!("00" <> _ = wkb) do
    IO.warn("passing a base-16 encoded string is deprecated, use a raw binary instead.")

    wkb
    |> Base.decode16!()
    |> decode!()
  end

  def decode!("01" <> _ = wkb) do
    IO.warn("passing a base-16 encoded string is deprecated, use a raw binary instead.")

    wkb
    |> Base.decode16!()
    |> decode!()
  end

  def decode!(wkb) do
    Decoder.decode(wkb) |> elem(0)
  end
end
