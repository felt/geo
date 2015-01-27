defmodule Geo do

  @type type :: :point | :line_string | :polygon | 
  :multi_point | :multi_line_string | :multi_polygon | 
  :geometry_collection | :geometry

  defimpl String.Chars, for: Geo.Geometry do  
    def to_string(geo) do
      Geo.WKT.encode(geo)
    end
  end

end
