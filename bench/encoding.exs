binaries_list_fn = fn i -> i |> Base.encode16() |> Geo.WKB.decode!() end
iodata_list_fn = fn i -> i |> Geo.WKB.decode_iodata!() end

Benchee.run(
  %{
    "binaries" => fn input -> Enum.map(input, binaries_list_fn) end,
    "io_data" => fn input -> Enum.map(input, iodata_list_fn) end
  },
  inputs: %{
    "Point" => List.duplicate(Base.decode16!("0101000000000000000000F03F000000000000F03F"), 10_000),
    "LineString" =>
      List.duplicate(
        Base.decode16!("0102000000030000000000000000003E40000000000000244000000000000024400000000000003E4000000000000044400000000000004440"),
        10_000
      )
  }
)
