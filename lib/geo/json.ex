defmodule Geo.JSON do
  alias Geo.JSON.{Decoder, Encoder}

  @moduledoc """
  Converts Geo structs to and from a map representing GeoJSON.


  You are responsible to encoding and decoding of JSON. This is so
  that you can use any JSON parser you want as well as making it
  so that you can use the resulting GeoJSON structure as a property
  in larger JSON structures.

  ```
  #Using Poison as the JSON parser for these examples

  json = "{ \\"type\\": \\"Point\\", \\"coordinates\\": [100.0, 0.0] }"
  geom = Poison.decode!(json) |> Geo.JSON.decode!(json)
  Geo.Point[coordinates: {100.0, 0.0}, srid: nil]

  Geo.JSON.encode!(geom) |> Poison.encode!
  "{ \\"type\\": \\"Point\\", \\"coordinates\\": [100.0, 0.0] }"

  Geo.JSON.encode!(geom)
  %{ "type" => "Point", "coordinates" => [100.0, 0.0] }
  ```
  """

  @doc """
  Takes a map representing GeoJSON and returns a Geometry
  """
  @spec decode!(Map.t()) :: Geo.geometry() | no_return
  defdelegate decode!(geo_json), to: Decoder

  @doc """
  Takes a map representing GeoJSON and returns a Geometry
  """
  @spec decode(Map.t()) :: {:ok, Geo.geometry()} | {:error, Decoder.DecodeError.t()}
  defdelegate decode(geo_json), to: Decoder

  @doc """
  Takes a Geometry and returns a map representing the GeoJSON
  """
  @spec encode!(Geo.geometry()) :: Map.t() | no_return
  defdelegate encode!(geom), to: Encoder

  @doc """
  Takes a Geometry and returns a map representing the GeoJSON
  """
  @spec encode(Geo.geometry()) :: {:ok, Map.t()} | {:error, Encoder.EncodeError.t()}
  defdelegate encode(geom), to: Encoder
end
