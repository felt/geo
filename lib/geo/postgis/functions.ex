defmodule Geo.PostGIS.Functions do
  @moduledoc """
    Postgis functions that can used in ecto queries
    [PostGIS Function Documentation](http://postgis.net/docs/manual-1.3/ch06.html)

    ex.
      defmodule Example do
        import Ecto.Query
        import Geo.PostGIS.Functions

        def example_query(geom) do
          from location in Location, limit: 5, select: st_distance(location.geom, ^geom)  
        end

      end  
  """


  defmacro st_distance(geometryA, geometryB) do
    quote do: fragment("ST_Distance(?,?)", unquote(geometryA), unquote(geometryB))
  end

  defmacro st_dwithin(geometryA, geometryB, float) do
    quote do: fragment("ST_Distance(?,?,?)", unquote(geometryA), unquote(geometryB), unquote(float))
  end

  defmacro st_equals(geometryA, geometryB) do
    quote do: fragment("ST_Equals(?,?)", unquote(geometryA), unquote(geometryB))
  end

  defmacro st_disjoint(geometryA, geometryB) do
    quote do: fragment("ST_Disjoint(?,?)", unquote(geometryA), unquote(geometryB))
  end

  defmacro st_intersects(geometryA, geometryB) do
    quote do: fragment("ST_Intersects(?,?)", unquote(geometryA), unquote(geometryB))
  end

  defmacro st_touches(geometryA, geometryB) do
    quote do: fragment("ST_Touches(?,?)", unquote(geometryA), unquote(geometryB))
  end

  defmacro st_crosses(geometryA, geometryB) do
    quote do: fragment("ST_Crosess(?,?)", unquote(geometryA), unquote(geometryB))
  end

  defmacro st_within(geometryA, geometryB) do
    quote do: fragment("ST_Within(?,?)", unquote(geometryA), unquote(geometryB))
  end

  defmacro st_overlaps(geometryA, geometryB) do
    quote do: fragment("ST_Overlaps(?,?)", unquote(geometryA), unquote(geometryB))
  end

  defmacro st_contains(geometryA, geometryB) do
    quote do: fragment("ST_Contains(?,?)", unquote(geometryA), unquote(geometryB))
  end

  defmacro st_covers(geometryA, geometryB) do
    quote do: fragment("ST_Covers(?,?)", unquote(geometryA), unquote(geometryB))
  end

  defmacro st_covered_by(geometryA, geometryB) do
    quote do: fragment("ST_CoveredBy(?,?)", unquote(geometryA), unquote(geometryB))
  end

  defmacro st_relate(geometryA, geometryB, intersectionPatternMatrix) do
    quote do: fragment("ST_Relate(?,?,?)", unquote(geometryA), unquote(geometryB), unquote(intersectionPatternMatrix))
  end

  defmacro st_relate(geometryA, geometryB) do
    quote do: fragment("ST_Relate(?,?)", unquote(geometryA), unquote(geometryB))
  end

  defmacro st_centroid(geometry) do
    quote do: fragment("ST_Centroid(?)", unquote(geometry))
  end

  defmacro st_area(geometry) do
    quote do: fragment("ST_Area(?)", unquote(geometry))
  end

  defmacro st_length(geometry) do
    quote do: fragment("ST_Length(?)", unquote(geometry))
  end

  defmacro st_point_on_surface(geometry) do
    quote do: fragment("ST_PointOnSurface(?)", unquote(geometry))
  end

  defmacro st_boundary(geometry) do
    quote do: fragment("ST_Boundary(?)", unquote(geometry))
  end

  defmacro st_buffer(geometry, double) do
    quote do: fragment("ST_Buffer(?, ?)", unquote(geometry),  unquote(double))
  end

  defmacro st_buffer(geometry, double, integer) do
    quote do: fragment("ST_Buffer(?, ?, ?)", unquote(geometry),  unquote(double),  unquote(integer))
  end

  defmacro st_convex_hull(geometry) do
    quote do: fragment("ST_ConvexHull(?)", unquote(geometry))
  end

  defmacro st_intersection(geometryA, geometryB) do
    quote do: fragment("ST_Intersection(?, ?)", unquote(geometryA), unquote(geometryB))
  end

  defmacro st_shift_longitude(geometry) do
    quote do: fragment("ST_Shift_Longitude(?)", unquote(geometry))
  end

  defmacro st_sym_difference(geometryA, geometryB) do
    quote do: fragment("ST_SymDifference(?,?)", unquote(geometryA), unquote(geometryB))
  end

  defmacro st_difference(geometryA, geometryB) do
    quote do: fragment("ST_Difference(?,?)", unquote(geometryA), unquote(geometryB))
  end

  defmacro st_union(geometryList) do
    quote do: fragment("ST_Union(?)", unquote(geometryList))
  end

  defmacro st_union(geometryA, geometryB) do
    quote do: fragment("ST_Union(?,?)", unquote(geometryA), unquote(geometryB))
  end

  defmacro st_mem_union(geometryList) do
    quote do: fragment("ST_MemUnion(?)", unquote(geometryList))
  end

  defmacro st_as_text(geometry) do
    quote do: fragment("ST_AsText(?)", unquote(geometry))
  end

  defmacro st_as_binary(geometry) do
    quote do: fragment("ST_AsBinary(?)", unquote(geometry))
  end

  defmacro st_srid(geometry) do
    quote do: fragment("ST_SRID(?)", unquote(geometry))
  end

  defmacro st_dimension(geometry) do
    quote do: fragment("ST_Dimension(?)", unquote(geometry))
  end

  defmacro st_envelope(geometry) do
    quote do: fragment("ST_Envelope(?)", unquote(geometry))
  end

  defmacro st_is_simple(geometry) do
    quote do: fragment("ST_IsSimple(?)", unquote(geometry))
  end

  defmacro st_is_closed(geometry) do
    quote do: fragment("ST_IsClosed(?)", unquote(geometry))
  end

  defmacro st_is_ring(geometry) do
    quote do: fragment("ST_IsRing(?)", unquote(geometry))
  end

  defmacro st_num_geometries(geometry) do
    quote do: fragment("ST_NumGeometries(?)", unquote(geometry))
  end

  defmacro st_geometry_n(geometry, int) do
    quote do: fragment("ST_GeometryN(?, ?)", unquote(geometry), unquote(int))
  end

  defmacro st_num_points(geometry) do
    quote do: fragment("ST_NumPoints(?)", unquote(geometry))
  end

  defmacro st_point_n(geometry, int) do
    quote do: fragment("ST_PointN(?, ?)", unquote(geometry), unquote(int))
  end

  defmacro st_exterior_ring(geometry) do
    quote do: fragment("ST_ExteriorRing(?)", unquote(geometry))
  end

  defmacro st_num_interior_rings(geometry) do
    quote do: fragment("ST_NumInteriorRings(?)", unquote(geometry))
  end

  defmacro st_num_interior_ring(geometry) do
    quote do: fragment("ST_NumInteriorRing(?)", unquote(geometry))
  end

  defmacro st_interior_ring_n(geometry, int) do
    quote do: fragment("ST_InteriorRingN(?, ?)", unquote(geometry), unquote(int))
  end

  defmacro st_end_point(geometry) do
    quote do: fragment("ST_EndPoint(?)", unquote(geometry))
  end

  defmacro st_start_point(geometry) do
    quote do: fragment("ST_StartPoint(?)", unquote(geometry))
  end

  defmacro st_geometry_type(geometry) do
    quote do: fragment("ST_GeometryType(?)", unquote(geometry))
  end

  defmacro st_x(geometry) do
    quote do: fragment("ST_X(?)", unquote(geometry))
  end

  defmacro st_y(geometry) do
    quote do: fragment("ST_Y(?)", unquote(geometry))
  end

  defmacro st_z(geometry) do
    quote do: fragment("ST_Z(?)", unquote(geometry))
  end

  defmacro st_m(geometry) do
    quote do: fragment("ST_M(?)", unquote(geometry))
  end

end