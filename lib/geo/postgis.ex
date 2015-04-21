defmodule Geo.PostGIS do

  @moduledoc """
    Postgis functions that can used in ecto queries
    [PostGIS Function Documentation](http://postgis.net/docs/manual-1.3/ch06.html)

    ex.
      defmodule Example do
        import Ecto.Query
        use Geo.PostGIS

        def example_query(geom) do
          from location in Location, limit: 5, select: st_distance(location.geom, ^geom)  
        end

      end  
  """

  defmacro __using__(_opts) do
    import Geo.PostGIS.OpenGIS
  end

end