binaries_list_fn = fn geom -> geom |> Geo.WKB.encode!() |> Geo.WKB.decode!() end
iodata_list_fn = fn geom -> geom |> Geo.WKB.encode_iodata!() |> Geo.WKB.decode_iodata!() end

Benchee.run(
  %{
    "binaries" => fn input -> Enum.map(input, binaries_list_fn) end,
    "io_data" => fn input -> Enum.map(input, iodata_list_fn) end
  },
  inputs: %{
    "Point" => List.duplicate(%Geo.Point{coordinates: {54.1745659, 15.5398456}, srid: 4326}, 10_000),
    "LineString" =>
      List.duplicate(
        %Geo.LineString{coordinates: [{30, 10}, {10, 30}, {40, 40}]},
        10_000
      )
  }
)
