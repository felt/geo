# v0.11.2

* Bug fixes
  * Correctly decoding WKB strings that caused invalid geometries to be produced when there is one element in a multi geometry

# v0.11.1

* Bug fixes
  * Fixed bug when decoding multi geometry wkb with one geometry inside would cause a crash

# v0.11.0

* Enhancements
  * Created structs for the supported geospatial types (Point, LineString, Polygon, MultiPoint, MultiLineString, MultiPolygon, GeometryCollection)
  * GeoJson module will encode the srid as a crs property if an srid exists

* Backwards incompatible changes
  * Removed the Geometry struct. Use one of the geometry type structs instead
  * The base coordinate pairs are now tuples ({0,0} instead of [0,0])
