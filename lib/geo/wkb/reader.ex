defmodule Geo.WKB.Reader do
  defstruct wkb: nil, endian: :xdr

  def start(wkb) do
    endian = if String.to_integer(String.slice(wkb, 0,2), 16) > 0 do
      :ndr
    else
      :xdr
    end

    %Geo.WKB.Reader{ wkb: String.slice(wkb, 2, String.length(wkb)), endian: endian }
  end

  def read(reader, count) do
    value = String.slice(reader.wkb, 0, count)

    if reader.endian == :ndr do
      value = Geo.Utils.reverse_byte_order(value)
    end

    { value, %{ reader | wkb: String.slice(reader.wkb, count, String.length(reader.wkb)) } }
  end

  def get_wkb(reader) do
    reader.wkb
  end

  def eof?(reader) do
    String.length(reader.wkb) == 0
  end
end