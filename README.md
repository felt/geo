# Geo

A collection of GIS functions. Below is a list of currently implemented features:

* The ability to encode and decode WKT

  ```
  iex(1)> point = Geo.WKT.decode("POINT(30 -90)")
  Geo.Geometry[type: :point, coordinates: [30, -90]]
  iex(2)> Geo.WKT.encode(point)
  "POINT(30 -90)"
  ```
