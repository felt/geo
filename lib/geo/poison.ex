if Code.ensure_loaded?(Poison) do
  defimpl Poison.Encoder, for: Geo.Point do
    def encode(%Geo.Point{ coordinates: {lat, long} }, _opts) do
      Poison.Encoder.encode(%{latitude: lat, longitude: long}, [])
    end
  end
end
