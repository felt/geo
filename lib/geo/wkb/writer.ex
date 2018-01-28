defmodule Geo.WKB.Writer do
  @moduledoc false
  defstruct wkb: nil, endian: :xdr

  def start(endian) do
    endian_hex = if endian == :ndr, do: "01", else: "00"
    %Geo.WKB.Writer{wkb: endian_hex, endian: endian}
  end

  def write(writer, value) do
    value = if writer.endian == :ndr, do: Geo.Utils.reverse_byte_order(value), else: value

    %{writer | wkb: writer.wkb <> value}
  end

  def write_no_endian(writer, value) do
    %{writer | wkb: writer.wkb <> value}
  end

  def get_wkb(writer) do
    writer.wkb
  end

  def get_endian(writer) do
    writer.endian
  end
end
