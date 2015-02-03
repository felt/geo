# v0.11.0

* Enhancements
  * Created structs for the supported geospatial types (Point, LineString, Polygon, MultiPoint, MultiLineString, MultiPolygon, GeometryCollection)
  * GeoJson module will encode the srid as a crs property if an srid exists

* Backwards incompatible changes
  * Removed the Geometry struct. Use one of the geometry type structs instead
  * The base coordinate pairs are now tuples ({0,0} instead of [0,0])
