defmodule Geo.WKB.Writer do
  defstruct wkb: nil, endian: :xdr

  def start(endian) do
    endian_hex = if endian == :ndr, do: "01", else: "00"
    %Geo.WKB.Writer{ wkb: endian_hex, endian: endian }
  end

  def write(writer, value) do
    if(writer.endian == :ndr)do
      value = Geo.Utils.reverse_byte_order(value)
    end

    %{ writer | wkb: writer.wkb <> value }
  end

  def write_no_endian(writer, value) do
    %{ writer | wkb: writer.wkb <> value }
  end

  def get_wkb(writer) do
    writer.wkb
  end

  def get_endian(writer) do
    writer.endian
  end
end