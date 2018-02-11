defmodule Geo.WKB.Reader do
  @moduledoc false
  defstruct wkb: nil, endian: :xdr

  def new(wkb) do
    <<endian::binary-size(2), wkb::binary>> = wkb

    endian =
      case endian do
        "01" -> :ndr
        "00" -> :xdr
      end

    %Geo.WKB.Reader{wkb: wkb, endian: endian}
  end

  def read(reader, count) do
    <<value::binary-size(count), _rest::binary>> = reader.wkb

    value = if reader.endian == :ndr, do: Geo.Utils.reverse_byte_order(value), else: value
    <<_rest::binary-size(count), wkb::binary>> = reader.wkb

    {value, %{reader | wkb: wkb}}
  end

  def eof?(reader) do
    byte_size(reader.wkb) == 0
  end
end
