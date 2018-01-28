defmodule Geo.WKB.Reader do
  @moduledoc false
  defstruct wkb: nil, endian: :xdr

  def start(wkb) do
    endian =
      if :binary.at(wkb, 1) == 49 do
        :ndr
      else
        :xdr
      end

    %Geo.WKB.Reader{wkb: :binary.part(wkb, 2, byte_size(wkb) - 2), endian: endian}
  end

  def read(reader, count) do
    value = :binary.part(reader.wkb, 0, count)

    value = if reader.endian == :ndr, do: Geo.Utils.reverse_byte_order(value), else: value

    {value, %{reader | wkb: :binary.part(reader.wkb, count, byte_size(reader.wkb) - count)}}
  end

  def get_wkb(reader) do
    reader.wkb
  end

  def eof?(reader) do
    byte_size(reader.wkb) == 0
  end
end
