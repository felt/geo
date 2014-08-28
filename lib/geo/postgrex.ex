defmodule Geo.Postgrex do
  alias Postgrex.TypeInfo

  @moduledoc """
    Encoder, Decoder, and Formatter to be used with Postgrex for PostGIS data types

    iex(1)> { :ok, pid } = Postgrex.Connection.start_link([hostname: "localhost", 
    username: "postgres", password: "postgres", database: "postgres", 
    encoder: &Geo.Postgrex.encoder/3, decoder: &Geo.Postgrex.decoder/4, 
    formatter: &Geo.Postgrex.formatter/1 ])

  """

  def decoder(%TypeInfo{sender: "geometry", type: "geometry"}, _format , _, value) do
    Geo.WKB.decode(value)
  end

  def decoder(%TypeInfo{}, _format, default, bin) do
    default.(bin)
  end

  def encoder(%TypeInfo{sender: "geometry", type: "geometry"}, _, value) do
    Geo.WKT.encode(value)
  end

  def encoder(%TypeInfo{}, default, value) do
    default.(value)
  end

  def formatter(%TypeInfo{sender: "geometry"}), do: :text
  def formatter(%TypeInfo{}), do: nil
end