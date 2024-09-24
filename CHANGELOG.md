# Changelog

## v4.0.1 — 2024-09-23

[Fix error raised when decoding JSON with string representations of integer values in coordinates](https://github.com/felt/geo/pull/221) by new contributor @IceDragon200.

## v4.0.0 — 2024-09-17

### Potentially breaking change: [Default decoded GeoJSON to SRID 4326 (WGS 84)](https://github.com/felt/geo/pull/219)

This aligns our GeoJSON decoding with [the GeoJSON spec](https://tools.ietf.org/html/rfc7946#section-4) by making all decoded GeoJSON infer the WGS 84 datum (SRID 4326) by default. Whereas previously when you called `Geo.JSON.decode/1` or `decode!/1`, we would return geometries with an `:srid` of `nil`, we now return `srid: 4326`. Likewise when encoding GeoJSON, we explicitly output a `crs` field indicating the datum.

This is unlikely to break real-world usage unless your implementation was assuming a different datum by default.

A couple examples of the changes:

**Before**:

```elixir
iex> Geo.JSON.decode!(%{"type" => "Point", "coordinates" => [1.0, 2.0]})
%Geo.Point{
  coordinates: {1.0, 2.0},
  # Note the old default nil SRID!
  srid: nil
}
```

**After**

```elixir
iex> Geo.JSON.decode!(%{"type" => "Point", "coordinates" => [1.0, 2.0]})
%Geo.Point{
  coordinates: {1.0, 2.0},
  # New explicit default of WGS 84
  srid: 4326
}
```

If you were to then encode this value again, you'd end up with a new `crs` field in the output GeoJSON:

```elixir
iex> %{"type" => "Point", "coordinates" => [1.0, 2.0]}
...> |> Geo.JSON.decode!()
...> |> GeoJSON.encode!()
%{
  "type" => "Point",
  "coordinates" => [1.0, 2.0],
  # Note the new `crs` field which was not present in the input to Geo.JSON.decode!/1
  "crs" => %{"properties" => %{"name" => "EPSG:4326"}, "type" => "name"}
}
```

This last behavior is the most potentially troublesome. However, we don't have a good way of distinguishing a case where you explicitly had the `crs` set in the input to the decoding function (in which case you would probably also like to have it present in the re-encoded version) compared to one in which it's been inferred.

Thanks to @gworkman for reporting this issue ([#129](https://github.com/felt/geo/issues/129)).

### Potentially breaking change: [Convert string coordinates to floats, or raise an error](https://github.com/felt/geo/pull/218)

This fixes an issue where we were silently accepting non-numeric coordinates in the GeoJSON decoder, such that you could wind up doing things like decoding a point like `%Geo.Point{coordinates: {"100.0", "-10.0"}}`. This would obviously not have gone well for you later in your processing pipeline, and it violates our typespecs.

The fix here, suggested by @LostKobrakai, is to convert those strings to numbers where we can do so unambiguously. While such inputs are clearly invalid, it's easy enough to handle them in the way that the user was hoping that we should probably just do it. In cases where there's any ambiguity at all, we raise an `ArgumentError`.

### Other bug fixes in v4.0.0

- [Support GeoJSON Feature object with nested GeometryCollection](https://github.com/felt/geo/pull/194) by new contributor @carstenpiepel (🎉)

### Other changes in v4.0.0

- [Fix typo in the README](https://github.com/felt/geo/pull/197) by @caspg
- [Fix typo](https://github.com/felt/geo/pull/216) by new contributor @preciz (🎉)
- [Optional dependency bump for `jason` to v1.4.4](https://github.com/felt/geo/pull/215)
- Dev dependency bumps for ex_doc, benchee, stream_data

## v3.6.0 — 2023-10-19

As of v3.6.0, `geo` (like [`geo_postgis`](https://github.com/felt/geo_postgis)) is being maintained by the Felt team. As a company building a geospatial product on Elixir, with a track record of [supporting open source software](https://felt.com/open-source), we're excited for the future of the project.

### New features

* [Add support for empty point](https://github.com/felt/geo/pull/172) by new contributor @bolek
* [Add support for LineStringZM](https://github.com/felt/geo/pull/171) by new contributor @kanatohodets
* [Support decoding MultiLineStringZ](https://github.com/felt/geo/pull/179) by new contributor @caspg

### Misc. changes

- Fix compile warnings ([#186](https://github.com/felt/geo/pull/186) by @s3cur3)
- Docs improvements ([#177](https://github.com/felt/geo/pull/177) by new contributor @ghecho, [#182](https://github.com/felt/geo/pull/182) by @s3cur3)
- Dependency updates: `ex_doc` ([#185](https://github.com/felt/geo/pull/185)), `jason` ([#183](https://github.com/felt/geo/pull/183)), `stream_data` ([#184](https://github.com/felt/geo/pull/184))

**Full Changelog**: https://github.com/felt/geo/compare/v3.5.1...v3.6.0

## v3.5.1 - 2023-06-07
- Fix
  - [Fix Application.get_env and use Bitwise warnings](https://github.com/felt/geo/pull/180)

## v3.5 - 2023-06-05
- Enhancement
  - [Support null feature geometries](https://github.com/felt/geo/pull/176)


## v3.4.3 - 2021-12-15
- Fix
  - [Handle MultiLineString with empty coordinates](https://github.com/felt/geo/pull/164)
  - [Clarify whether functions in Geo.WKB accept or return base16 or bytes](https://github.com/felt/geo/pull/166)

## v3.4.2 - 2021-04-11

- Fix
  - [Do not accept iodata for decoding](https://github.com/felt/geo/pull/158)

## v3.4.1 - 2021-04-10

- Fix
  - [Update Specs](https://github.com/felt/geo/pull/157)

## v3.4.0 - 2021-04-09

- Add
  - `Geo.WKB.encode_to_iodata`

- Enhancements
  - The implementation of encoding and decoding WKBs has been updated to use iodata instead of binaries, improving overall performance.
  - `Geo.WKB.decode!` and `Geo.WKB.decode` can now take iodata in addition to binary data

## v3.3.8 - 2021-04-02

- Fix
  - [Misc doc changes](https://github.com/felt/geo/pull/153)

## v3.3.7 - 2020-11-20

- Fix
  - [Make Jason optional](https://github.com/felt/geo/pull/149)

## v3.3.6 - 2020-11-05

- Enhancement
  - [Replace Poison with Jason for JSON encoding in tests](https://github.com/felt/geo/pull/141)
  - [Add JSON decoding support for LineStringZ](https://github.com/felt/geo/pull/147)

## v3.3.5 - 2020-08-26

- Fixed
  - Typespec on Point

## v3.3.4 - 2020-08-07

- Fixed
  - [Update typespec to make Point easier to use](https://github.com/felt/geo/pull/140)

## v3.3.3 - 2019-12-13

- Fixed
  - [Add missing MultiPointZ in list of geometry types](https://github.com/felt/geo/pull/122)
  - [Improve docs around Geo.endian type](https://github.com/felt/geo/pull/123)

## v3.3.2 - 2019-08-26

- Fixed
  - Some optimizations based on benchmarking

## v3.3.1 - 2019-08-26

- Fixed
  - Bugs found while property testing

## v3.3.0 - 2019-08-20

- Added
  - [Updated Type Specs](https://github.com/felt/geo/pull/116)
  - [Allow to disable String.Chars implementation for Geo objects](https://github.com/felt/geo/pull/110)

## v3.2.0 - 2019-07-23

- Added
  - [3D versions of the various datatypes](https://github.com/felt/geo/pull/111)

## v3.1.0 - 2019-02-08

- Fixed
  - [Optimise reverse_byte_order/1](https://github.com/felt/geo/pull/107)

- Added
  - [Support WKB empty multipolygons](https://github.com/felt/geo/pull/100)
  - [Add PointZ support to Geo.Json](https://github.com/felt/geo/pull/99)

## v3.0.0 - 2018-04-14

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
  - All Ecto.Type behaviour implementations were removed. This may not effect too many people, but it was moved to the [geo_postgis](https://github.com/felt/geo_postgis) package

## v2.1.0 - 2018-01-28

- Fix
  - Make stricter patterns for casts functions so that error pattern is used when types are wrong
  - [Change handling of EPSG/SRID to match standard](https://github.com/felt/geo/pull/79)
  - [Fix String.strip() deprecations in Elixir 1.5+](https://github.com/felt/geo/pull/78)

## v2.0.0 - 2017-07-15

- Breaking
  - Split out PostGIS functionality into its own library, [geo_postgis](https://github.com/felt/geo_postgis)

## v1.5.0 - 2017-06-10

- Enhancement
  - [Add `st_distancesphere/2`](https://github.com/felt/geo/pull/69)

## v1.4.1 - 2017-02-17

- Fixes
  - [Updated ecto related documentation on Geo module](https://github.com/felt/geo/pull/66)

## v1.4.0 - 2017-02-17

- Enhancements
  - [Add `st_dwithin_in_meters\3`](https://github.com/felt/geo/pull/64)
  - [Make sure an srid of 0 does not show srid in WKT](https://github.com/felt/geo/pull/63)
  - [Add types PointZ, PointM and PointZM](https://github.com/felt/geo/pull/56)

## v1.3.1 - 2016-12-24

- Enhancements
  - Relax Poison dependency requirement

## v1.3.0 - 2016-12-19

- Enhancements

  - [Support new Postgrex 0.13 Extension API](https://github.com/felt/geo/pull/53)

- Breaking
  - Now only supports Postgrex 0.13+
  - Now only supports Ecto 2.1+

## v1.2.1 - 2016-11-04

- Enhancements
  - [add st_transform](https://github.com/felt/geo/pull/51)

## v1.2.0 - 2016-10-26

- Enhancements
  - [add st_distance_sphere](https://github.com/felt/geo/pull/49)

## v1.1.2 - 2016-09-14

- Bug Fixes
  - WKBs that are GeometryCollections with one element should now properly decode

## v1.1.1 - 2016-07-19

- Enhancements
  - Added `Geo.JSON.EncodeError` and `Geo.JSON.DecodeError` thrown whenever `Geo.JSON.encode` or `Geo.JSON.decode` are given invalid data

## v1.1.0 - 2016-07-09

- Enhancements
  - Add Geo.Geometry custom Ecto type to allow multiple geometries in a single field

## v1.0.6 - 2016-06-26

- Enhancements
  - Fixed warnings that appeared in Elixir 1.3

## v1.0.5 - 2016-06-22

- Enhancements
  - Update to allow use with Ecto 2.0

## v1.0.4 - 2016-05-23

- Enhancements
  - Ecto.Type: matching on geojson properties so that Ecto.DataType can be used by users

## v1.0.3 - 2016-05-14

- Enhancements
  - Updated dependencies to allow for using ecto 2.0 release candidate versions

## v1.0.2 - 2016-04-03

- Enhancements
  - Updated dependencies to allow for using ecto 2.0 beta versions

## v1.0.1 - 2016-01-31

- Enhancements
  - Updated Postgrex and Poison optional dependencies

## v1.0.0 - 2015-11-29

## v0.18.0 - 2015-11-11

- Enhancements
  - Made Postgrex, Ecto, and Poison optional dependencies

## v0.17.0 - 2015-10-13

- Breaking
  - Geo.JSON.encode and Geo.JSON.decode now do not do any JSON parsing at all and
    instead work on a map representation of GeoJSON. All JSON encoding and decoding
    must be done before or after calling those functions.

## v0.16.1 - 2015-08-27

- Enhancements
  - Made Postgrex a required dependency

## v0.16.0 - 2015-08-27

- Enhancements
  - Updated to Ecto 1.0

## v0.15.2 - 2015-08-10

- Enhancements
  - Added an `opts` parameter to `Geo.JSON.encode` to allow for skipping JSON encoding

## v0.15.1 - 2015-07-27

- Enhancements
  - Fixed st_dwithin macro

## v0.15.0 - 2015-07-24

- Enhancements
  - Updated cast function on structs to handle maps and strings
  - Now reading the srid from geo json

## v0.14.0 - 2015-07-19

- Enhancements
  - Basic Support for Geography datatype

## v0.13.0 - 2015-06-08

- Enhancements

  - Added PostGIS function macros for use in Ecto Queries. Currently only the OpenGIS ones

- Breaking
  - `Geo.PostGIS` is now `Geo.PostGIS.Extension`
  - Changed from Jazz to Poison for JSON encoding and decoding

## v0.12.0 - 2015-03-08

- Enhancements
  - Geo.PostGIS is now a Postgrex Extension
  - Updated to work with latest version of Ecto

## v0.11.2 - 2015-02-13

- Bug fixes
  - Correctly decoding WKB strings that caused invalid geometries to be produced when there is one element in a multi geometry

## v0.11.1 - 2015-02-12

- Bug fixes
  - Fixed bug when decoding multi geometry wkb with one geometry inside would cause a crash

## v0.11.0 - 2015-02-03

- Enhancements

  - Created structs for the supported geospatial types (Point, LineString, Polygon, MultiPoint, MultiLineString, MultiPolygon, GeometryCollection)
  - GeoJson module will encode the srid as a crs property if an srid exists

- Backwards incompatible changes
  - Removed the Geometry struct. Use one of the geometry type structs instead
  - The base coordinate pairs are now tuples ({0,0} instead of [0,0])
