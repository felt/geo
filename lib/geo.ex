defmodule Geo do

  defmodule Geometry do
    defstruct type: :geometry, coordinates: [], srid: nil
  end

  defimpl String.Chars, for: Geo.Geometry do  
    def to_string(geo) do
      Geo.WKT.encode(geo)
    end
  end
end
