defmodule Geo.Utils.Test do
  use ExUnit.Case, async: true

  test "Hex String to Float Conversion" do
    assert(Geo.Utils.hex_to_float("40000000") == 2.0)
    assert(Geo.Utils.hex_to_float("C0000000") == -2.0)
    assert(Geo.Utils.hex_to_float("3f800000") == 1.0)
    assert(Geo.Utils.hex_to_float("41c80000") == 25.0)
    assert(Geo.Utils.hex_to_float("46EA6000") == 30000.0)
    assert(Geo.Utils.hex_to_float("C2ED4000") == -118.625)

    assert(Geo.Utils.hex_to_float("3ff0000000000000") == 1.0)
    assert(Geo.Utils.hex_to_float("4000000000000000") == 2.0)
    assert(Geo.Utils.hex_to_float("C000000000000000") == -2.0)
    assert(Geo.Utils.hex_to_float("40DD4C0000000000") == 30000.0)
  end

  test "Hex Integer to Float Conversion" do
    assert(Geo.Utils.hex_to_float(0x40000000) == 2.0)
    assert(Geo.Utils.hex_to_float(0xC0000000) == -2.0)
    assert(Geo.Utils.hex_to_float(0x3F800000) == 1.0)
    assert(Geo.Utils.hex_to_float(0x41C80000) == 25.0)
    assert(Geo.Utils.hex_to_float(0x46EA6000) == 30000.0)
    assert(Geo.Utils.hex_to_float(0xC2ED4000) == -118.625)

    assert(Geo.Utils.hex_to_float(0x3FF0000000000000) == 1.0)
    assert(Geo.Utils.hex_to_float(0x4000000000000000) == 2.0)
    assert(Geo.Utils.hex_to_float(0xC000000000000000) == -2.0)
    assert(Geo.Utils.hex_to_float(0x40DD4C0000000000) == 30000.0)
  end

  test "Hex Float to Hex Conversion" do
    assert(Geo.Utils.float_to_hex(2.0, 32) == 0x40000000)
    assert(Geo.Utils.float_to_hex(-2.0, 32) == 0xC0000000)
    assert(Geo.Utils.float_to_hex(1.0, 32) == 0x3F800000)
    assert(Geo.Utils.float_to_hex(25.0, 32) == 0x41C80000)
    assert(Geo.Utils.float_to_hex(30000.0, 32) == 0x46EA6000)
    assert(Geo.Utils.float_to_hex(-118.625, 32) == 0xC2ED4000)

    assert(Geo.Utils.float_to_hex(1.0, 64) == 0x3FF0000000000000)
    assert(Geo.Utils.float_to_hex(2.0, 64) == 0x4000000000000000)
    assert(Geo.Utils.float_to_hex(-2.0, 64) == 0xC000000000000000)
    assert(Geo.Utils.float_to_hex(30000.0, 64) == 0x40DD4C0000000000)
  end
end
