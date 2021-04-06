binaries_list = List.duplicate("0102000000030000000000000000003E40000000000000244000000000000024400000000000003E4000000000000044400000000000004440", 1_000)
binaries_list_fn = fn i -> Geo.WKB.decode!(i) end

iodata_list = List.duplicate(Base.decode16!("0102000000030000000000000000003E40000000000000244000000000000024400000000000003E4000000000000044400000000000004440"), 1_000)
iodata_list_fn = fn i -> Geo.WKB.decode_iodata!(i) end

Benchee.run(
  %{
    "binaries" => fn -> Enum.map(binaries_list, binaries_list_fn) end,
    "io_data" => fn -> Enum.map(iodata_list, iodata_list_fn) end
  }
)
