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
  @spec encode!(Geo.geometry(), Geo.endian()) :: binary | no_return
  defdelegate encode!(geom, endian \\ :xdr), to: Encoder

  @doc """
  Takes a Geometry and returns a WKB string. The endian decides
  what the byte order will be.
  """
  @spec encode(binary, Geo.endian()) :: {:ok, binary} | {:error, Exception.t()}
  defdelegate encode(geom, endian \\ :xdr), to: Encoder

  @doc """
  Takes a WKB as iodata and returns a Geometry.
  """
  @spec decode_iodata(iodata()) :: {:ok, Geo.geometry()} | {:error, Exception.t()}
  def decode_iodata(wkb) do
    {:ok, Decoder.decode_iodata!(wkb) |> elem(0)}
  rescue
    exception ->
      {:error, exception}
  end

  @doc """
  Takes a WKB as iodata and returns a Geometry.
  """
  @spec decode_iodata!(iodata()) :: Geo.geometry() | no_return
  def decode_iodata!(wkb) do
    Decoder.decode_iodata!(wkb) |> elem(0)
  end

  @doc """
  Takes a WKB string and returns a Geometry.
  """
  @spec decode(binary) :: {:ok, Geo.geometry()} | {:error, Exception.t()}
  def decode(wkb) do
    wkb
    |> Base.decode16!()
    |> decode_iodata()
  end

  @doc """
  Takes a WKB string and returns a Geometry.
  """
  @spec decode!(binary) :: Geo.geometry() | no_return
  def decode!(wkb) do
    wkb
    |> Base.decode16!()
    |> decode_iodata!()
  end
end
