defmodule Geo.Utils do
  use Bitwise

  @doc """
  Turns a hex string or an integer of base 16 into its floating point
  representation.

  Takes an optional endian atom. Either :xdr for big endian or :ndr for little
  endian. Defaults to :xdr

  iex(1)> Geo.Utils.hex_to_float("40000000")
  2.0
  iex(2)> Geo.Utils.hex_to_float(0x40000000)
  2.0
  iex(3)> Geo.Utils.hex_to_float("3ff0000000000000")
  1.0
  iex(4)> Geo.Utils.hex_to_float(0x3ff0000000000000)
  1.0

  """
  def hex_to_float(hex) when is_integer(hex) or is_binary(hex) do
    if is_integer(hex), do: hex = integer_to_binary(hex, 16)

    case bit_size(hex) do
      64 ->
        << value :: [float, 32] >> = << binary_to_integer(hex, 16) :: [integer, 32] >>
        value
      128 ->
        << value :: [float, 64] >> = << binary_to_integer(hex, 16) :: [integer, 64] >>
        value
      _ ->
        raise ArgumentError.new message: "hex must be either 4 or 8 bytes long"
    end
  end

  def float_to_hex(float, size) do
    case size do
      32 ->
        << value :: [integer, 32] >> = << float :: [float, 32] >>
        value
      _ ->
        << value :: [integer, 64] >> = << float :: [float, 64] >>
        value
    end
  end

  @doc """
    Reverses the byte order of the given hex string.

    iex(1)> Geo.Utils.reverse_byte_order("00000004")
    "40000000"
    iex(2)> Geo.Utils.reverse_byte_order("E6100000")
    "000010E6"
  """
  def reverse_byte_order(hex) do
    byte_range = Enum.to_list(0..(div(String.length(hex),2)-1))
    Enum.map(byte_range, fn(x) -> String.slice(hex, x*2, 2) end)
    |> Enum.reverse
    |> Enum.join
  end

  def pad_right(hex, size) do
    if String.length(hex) == size do
      hex
    else
      hex <> repeat("0", size - String.length(hex))
    end
  end

  def pad_left(hex, size) do
    if String.length(hex) == size do
      hex
    else
      repeat("0", size - String.length(hex)) <> hex
    end
  end

  def repeat(char, count) do
    Enum.map(1..count, fn(_x) -> char end) |> Enum.join
  end

  def ldexp(x, i) do
    x * :math.pow(2, i)
  end

end
