defmodule Geo.WKB.Reader do
  @moduledoc false
  defstruct wkb: nil, endian: :xdr

  def new(<<"01", wkb::binary>>) do
    %Geo.WKB.Reader{wkb: wkb, endian: :ndr}
  end

  def new(<<"00", wkb::binary>>) do
    %Geo.WKB.Reader{wkb: wkb, endian: :xdr}
  end

  def read(%{endian: :ndr} = reader, count) do
    <<value::binary-size(count), _rest::binary>> = reader.wkb

    value = Geo.Utils.reverse_byte_order(value)
    <<_rest::binary-size(count), wkb::binary>> = reader.wkb

    {value, %{reader | wkb: wkb}}
  end

  def read(%{endian: :xdr} = reader, count) do
    <<value::binary-size(count), _rest::binary>> = reader.wkb

    <<_rest::binary-size(count), wkb::binary>> = reader.wkb

    {value, %{reader | wkb: wkb}}
  end

  def eof?(reader) do
    byte_size(reader.wkb) == 0
  end
end
