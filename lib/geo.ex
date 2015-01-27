defmodule Geo do

  defimpl String.Chars, for: Geo.Geometry do  
    def to_string(geo) do
      Geo.WKT.encode(geo)
    end
  end

end
