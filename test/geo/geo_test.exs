defmodule Geo.Test do
  use ExUnit.Case, async: true

  test "to_string" do
    geom = %Geo.Point{coordinates: {100.0, 0.0}}
    assert to_string(geom) == "POINT(100.0 0.0)"
  end
end
