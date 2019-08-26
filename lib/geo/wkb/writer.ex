defmodule Geo.WKB.Writer do
  @moduledoc false
  defstruct wkb: nil, endian: :xdr

  def new(:ndr) do
    %Geo.WKB.Writer{wkb: "01", endian: :ndr}
  end

  def new(:xdr) do
    %Geo.WKB.Writer{wkb: "00", endian: :xdr}
  end

  def write(%{endian: :ndr} = writer, value) do
    value = Geo.Utils.reverse_byte_order(value)

    %{writer | wkb: writer.wkb <> value}
  end

  def write(%{endian: :xdr} = writer, value) do
    %{writer | wkb: writer.wkb <> value}
  end

  def write_no_endian(writer, value) do
    %{writer | wkb: writer.wkb <> value}
  end
end
