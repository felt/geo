# Run from the project root with $ mix run bench/benchmarks.exs

binaries_list_fn = fn geom -> geom |> Geo.WKB.encode!() |> Geo.WKB.decode!() end
iodata_list_fn = fn geom -> geom |> Geo.WKB.encode_to_iodata() |> IO.iodata_to_binary() |> Geo.WKB.decode!() end

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
