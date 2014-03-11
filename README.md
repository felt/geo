# Geo

A collection of GIS functions. Below is a list of currently implemented features:

* The ability to encode and decode WKT and EWKT

  ```
    iex(1)> point = Geo.WKT.decode("POINT(30 -90)")
    Geo.Geometry[type: :point, coordinates: [30, -90], srid: nil]

    iex(2)> Geo.WKT.encode(point)
    "POINT(30 -90)"

    iex(3)> point = Geo.WKT.decode("SRID=4326;POINT(30 -90)")
    Geo.Geometry[type: :point, coordinates: [30, -90], srid: 4326]
  ```


* The ability to encode and decode WKB and EWKB

  ```
    iex(1)> point = Geo.WKB.decode("0101000000000000000000F03F000000000000F03F")
    Geo.Geometry[type: :point, coordinates: [1.0, 1.0], srid: nil]

    iex(2)> Geo.WKB.encode(point)
    "00000000013FF00000000000003FF0000000000000"

    iex(3)> point = Geo.WKB.decode("0101000020E61000009EFB613A637B4240CF2C0950D3735EC0")
    Geo.Geometry[type: :point, coordinates: [36.9639657, -121.8097725], srid: 4326]

    iex(4)> Geo.WKB.encode(point)
    "0020000001000010E640427B633A61FB9EC05E73D350092CCF"
  ```
