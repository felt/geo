defmodule Geo.JSON do
  @moduledoc """
  Converts Geo structs to and from a map representing GeoJSON.

  You are responsible to encoding and decoding of JSON. This is so
  that you can use any JSON parser you want as well as making it
  so that you can use the resulting GeoJSON structure as a property
  in larger JSON structures.

  Note that, per [the GeoJSON spec](https://tools.ietf.org/html/rfc7946#section-4),
  all geometries are assumed to use the WGS 84 datum (SRID 4326) by default.

  ## Examples

      # Using JSON or Jason as the JSON parser for these examples

      iex> json = "{ \\"type\\": \\"Point\\", \\"coordinates\\": [100.0, 0.0] }"
      ...> json |> (if Code.ensure_loaded?(JSON), do: JSON, else: Jason).decode!() |> Geo.JSON.decode!()
      %Geo.Point{coordinates: {100.0, 0.0}, srid: 4326}

      iex> geom = %Geo.Point{coordinates: {100.0, 0.0}, srid: nil}
      ...> (if Code.ensure_loaded?(JSON), do: JSON, else: Jason).encode!(geom)
      "{\\"coordinates\\":[100.0,0.0],\\"type\\":\\"Point\\"}"

      iex> geom = %Geo.Point{coordinates: {100.0, 0.0}, srid: nil}
      ...> Geo.JSON.encode!(geom)
      %{"type" => "Point", "coordinates" => [100.0, 0.0]}

  """

  alias Geo.JSON.{Decoder, Encoder}

  @doc """
  Takes a map representing GeoJSON and returns a Geometry.
  """
  @spec decode!(map()) :: Geo.geometry()
  defdelegate decode!(geo_json), to: Decoder

  @doc """
  Takes a map representing GeoJSON and returns a Geometry.
  """
  @spec decode(map()) :: {:ok, Geo.geometry()} | {:error, Decoder.DecodeError.t()}
  defdelegate decode(geo_json), to: Decoder

  @doc """
  Takes a Geometry and returns a map representing the GeoJSON.
  """
  @spec encode!(Geo.geometry()) :: map()
  defdelegate encode!(geom), to: Encoder
  defdelegate encode!(geom, opts), to: Encoder

  @doc """
  Takes a Geometry and returns a map representing the GeoJSON.
  """
  @spec encode(Geo.geometry()) :: {:ok, map()} | {:error, Encoder.EncodeError.t()}
  defdelegate encode(geom), to: Encoder
  defdelegate encode(geom, opts), to: Encoder
end
