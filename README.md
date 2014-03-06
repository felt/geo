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
