defmodule Geo.Poison.Test do
  use ExUnit.Case, async: true

  test "Point to JSON" do
    geom = %Geo.Point{ coordinates: {100.0, 0.0} }
    {:ok, json} = Poison.encode(geom)

    assert(json == "{\"longitude\":0.0,\"latitude\":100.0}")
  end
end
