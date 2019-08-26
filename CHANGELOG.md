## v3.3.2

- Fixed
  - Some optimizations based on benchmarking

## v3.3.1

- Fixed
  - Bugs found while property testing

## v3.3.0

- Added
  - [Updated Type Specs](https://github.com/bryanjos/geo/pull/116)
  - [Allow to disable String.Chars implementation for Geo objects](https://github.com/bryanjos/geo/pull/110)

## v3.2.0

- Added
  - [3D versions of the various datatypes](https://github.com/bryanjos/geo/pull/111)

## v3.1.1

- Fixed
  - [Optimise reverse_byte_order/1](https://github.com/bryanjos/geo/pull/107)

## v3.1.0

- Added
  - [Support WKB empty multipolygons](https://github.com/bryanjos/geo/pull/100)
  - [Add PointZ support to Geo.Json](https://github.com/bryanjos/geo/pull/99)

## v3.0.0

- Add

  - `Geo.WKT.encode!`
  - `Geo.WKT.decode!`
  - `Geo.WKB.encode!`
  - `Geo.WKB.decode!`
  - `Geo.JSON.encode!`
  - `Geo.JSON.decode!`

- Enhancement

  - Geometry struct now have a `properties` field. This is used to convert GeoJSON properties

- Breaking

  - `Geo.WKT.encode` now returns either `{:ok, binary}` or `{:error, exception}`
  - `Geo.WKT.decode` now returns either `{:ok, geometry}` or `{:error, exception}`
  - `Geo.WKB.encode` now returns either `{:ok, binary}` or `{:error, exception}`
  - `Geo.WKB.decode` now returns either `{:ok, geometry}` or `{:error, exception}`
  - `Geo.JSON.encode` now returns either `{:ok, map}` or `{:error, exception}`
  - `Geo.JSON.decode` now returns either `{:ok, geom}` or `{:error, exception}`
  - All Ecto.Type behaviour implementations were removed. This may not effect too many people, but it was moved to the [geo_postgis](https://github.com/bryanjos/geo_postgis) package

# v2.1.0

- Fix
  - Make stricter patterns for casts functions so that error pattern is used when types are wrong
  - [Change handling of EPSG/SRID to match standard](https://github.com/bryanjos/geo/pull/79)
  - [Fix String.strip() deprecations in Elixir 1.5+](https://github.com/bryanjos/geo/pull/78)

# v2.0.0

- Breaking
  - Split out PostGIS functionality into its own library, [geo_postgis](https://github.com/bryanjos/geo_postgis)

# v1.5.0

- Enhancement
  - [Add `st_distancesphere/2`](https://github.com/bryanjos/geo/pull/69)

# v1.4.1

- Fixes
  - [Updated ecto related documentation on Geo module](https://github.com/bryanjos/geo/pull/66)

# v1.4.0

- Enhancements
  - [Add `st_dwithin_in_meters\3`](https://github.com/bryanjos/geo/pull/64)
  - [Make sure an srid of 0 does not show srid in WKT](https://github.com/bryanjos/geo/pull/63)
  - [Add types PointZ, PointM and PointZM](https://github.com/bryanjos/geo/pull/56)

# v1.3.1

- Enhancements
  - Relax Poison dependency requirement

# v1.3.0

- Enhancements

  - [Support new Postgrex 0.13 Extension API](https://github.com/bryanjos/geo/pull/53)

- Breaking
  - Now only supports Postgrex 0.13+
  - Now only supports Ecto 2.1+

# v1.2.1

- Enhancements
  - [add st_transform](https://github.com/bryanjos/geo/pull/51)

# v1.2

- Enhancements
  - [add st_distance_sphere](https://github.com/bryanjos/geo/pull/49)

# v1.1.2

- Bug Fixes
  - WKBs that are GeometryCollections with one element should now properly decode

# v1.1.1

- Enhancements
  - Added `Geo.JSON.EncodeError` and `Geo.JSON.DecodeError` thrown whenever `Geo.JSON.encode` or `Geo.JSON.decode` are given invalid data

# v1.1

- Enhancements
  - Add Geo.Geometry custom Ecto type to allow multiple geometries in a single field

# v1.0.6

- Enhancements
  - Fixed warnings that appeared in Elixir 1.3

# v1.0.5

- Enhancements
  - Update to allow use with Ecto 2.0

# v1.0.4

- Enhancements
  - Ecto.Type: matching on geojson properties so that Ecto.DataType can be used by users

# v1.0.3

- Enhancements
  - Updated dependencies to allow for using ecto 2.0 release candidate versions

# v1.0.2

- Enhancements
  - Updated dependencies to allow for using ecto 2.0 beta versions

# v1.0.1

- Enhancements
  - Updated Postgrex and Poison optional dependencies

# v1.0.0

# v0.18.0

- Enhancements
  - Made Postgrex, Ecto, and Poison optional dependencies

# v0.17.0

- Breaking
  - Geo.JSON.encode and Geo.JSON.decode now do not do any JSON parsing at all and
    instead work on a map representation of GeoJSON. All JSON encoding and decoding
    must be done before or after calling those functions.

# v0.16.1

- Enhancements
  - Made Postgrex a required dependency

# v0.16.0

- Enhancements
  - Updated to Ecto 1.0

# v0.15.2

- Enhancements
  - Added an `opts` parameter to `Geo.JSON.encode` to allow for skipping JSON encoding

# v0.15.1

- Enhancements
  - Fixed st_dwithin macro

# v0.15.0

- Enhancements
  - Updated cast function on structs to handle maps and strings
  - Now reading the srid from geo json

# v0.14.0

- Enhancements
  - Basic Support for Geography datatype

# v0.13.0

- Enhancements

  - Added PostGIS function macros for use in Ecto Queries. Currently only the OpenGIS ones

- Breaking
  - `Geo.PostGIS` is now `Geo.PostGIS.Extension`
  - Changed from Jazz to Poison for JSON encoding and decoding

# v0.12.0

- Enhancements
  - Geo.PostGIS is now a Postgrex Extension
  - Updated to work with latest version of Ecto

# v0.11.2

- Bug fixes
  - Correctly decoding WKB strings that caused invalid geometries to be produced when there is one element in a multi geometry

# v0.11.1

- Bug fixes
  - Fixed bug when decoding multi geometry wkb with one geometry inside would cause a crash

# v0.11.0

- Enhancements

  - Created structs for the supported geospatial types (Point, LineString, Polygon, MultiPoint, MultiLineString, MultiPolygon, GeometryCollection)
  - GeoJson module will encode the srid as a crs property if an srid exists

- Backwards incompatible changes
  - Removed the Geometry struct. Use one of the geometry type structs instead
  - The base coordinate pairs are now tuples ({0,0} instead of [0,0])
