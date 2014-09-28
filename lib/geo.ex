defmodule Geo do
  defmodule Geometry do
    defstruct type: :geometry, coordinates: [], srid: nil
  end

  defimpl String.Chars, for: Geo.Geometry do  
    def to_string(geo) do
      Geo.WKT.encode(geo)
    end
  end

  def contains(%{ type: :point, coordinates: coordinates1}, %{ type: :point, coordinates: coordinates2}) do
    is_pair_equal?(coordinates1, coordinates2)
  end

  def contains(%{ type: :line_string, coordinates: coordinates1}, %{ type: :point, coordinates: coordinates2}) do
    Enum.find(coordinates1, fn(x) -> is_pair_equal?(x, coordinates2)  end) != nil
  end

  defp is_pair_equal?(p1, p2) do
    List.first(p1) == List.first(p2) && List.last(p1) ==  List.last(p2)
  end
end
