# Geo

A collection of GIS functions. Handles conversions to and from WKT, WKB, and GeoJSON for the following geometries:

* Point
* LineString
* Polygon
* MultiPoint
* MulitLineString
* MultiPolygon
* GeometryCollection


Also includes an encoder, decoder, and formatter for using PostGIS data types with Postgrex

```
  defp deps do
    [{:geo, "~> 0.8.0"}]
  end
```


## Examples



* Encode and decode WKT and EWKT

  ```
    iex(1)> point = Geo.WKT.decode("POINT(30 -90)")
    %Geo.Geometry{type: :point, coordinates: [30, -90], srid: nil}

    iex(2)> Geo.WKT.encode(point)
    "POINT(30 -90)"

    iex(3)> point = Geo.WKT.decode("SRID=4326;POINT(30 -90)")
    %Geo.Geometry{type: :point, coordinates: [30, -90], srid: 4326}
  ```


* Encode and decode WKB and EWKB

  ```
    iex(1)> point = Geo.WKB.decode("0101000000000000000000F03F000000000000F03F")
    %Geo.Geometry{ type: :point, coordinates: [1.0, 1.0], srid: nil }

    iex(2)> Geo.WKB.encode(point)
    "00000000013FF00000000000003FF0000000000000"

    iex(3)> point = Geo.WKB.decode("0101000020E61000009EFB613A637B4240CF2C0950D3735EC0")
    %Geo.Geometry{ type: :point, coordinates: [36.9639657, -121.8097725], srid: 4326 }

    iex(4)> Geo.WKB.encode(point)
    "0020000001000010E640427B633A61FB9EC05E73D350092CCF"
  ```

* Encode and decode GeoJSON

  ```
    iex(1)> point = Geo.JSON.decode("{ \"type\": \"Point\", \"coordinates\": [100.0, 0.0] }")
    %Geo.Geometry{ type: :point, coordinates: [100.0, 0.0], srid: nil }

    iex(2)> Geo.JSON.encode(point)
    "{\"type\":\"Point\",\"coordinates\":[100.0,0.0]}"
  ```

* Encoder, Decoder, and Formatter to be used with Postgrex for PostGIS data types

  ```
    iex(1)>     opts = [hostname: "localhost",
    ...(1)>     username: "postgres", database: "geo_postgrex_test",
    ...(1)>     encoder: &Geo.PostGIS.encoder/3, decoder: &Geo.PostGIS.decoder/4,
    ...(1)>     formatter: &Geo.PostGIS.formatter/1 ]
    [hostname: "localhost", username: "postgres", database: "geo_postgrex_test",
     encoder: &Geo.PostGIS.encoder/3, decoder: &Geo.PostGIS.decoder/4,
     formatter: &Geo.PostGIS.formatter/1]

    iex(2)> {:ok, pid} = Postgrex.Connection.start_link(opts)
    {:ok, #PID<0.115.0>}

    iex(3)> geo = %Geo.Geometry{type: :point, coordinates: [30, -90], srid: 4326}
    %Geo.Geometry{coordinates: [30, -90], srid: 4326, type: :point}
    
    iex(4)> {:ok, _} = Postgrex.Connection.query(pid, "CREATE TABLE point_test (id int, geom geometry(Point, 4326))")
    {:ok,
     %Postgrex.Result{columns: nil, command: :create_table, num_rows: 0, rows: nil}}
    
    iex(5)> {:ok, _} = Postgrex.Connection.query(pid, "INSERT INTO point_test VALUES ($1, $2)", [42, geo])
    {:ok, %Postgrex.Result{columns: nil, command: :insert, num_rows: 1, rows: nil}}
    
    iex(6)> Postgrex.Connection.query(pid, "SELECT * FROM point_test")
    {:ok,
     %Postgrex.Result{columns: ["id", "geom"], command: :select, num_rows: 1,
      rows: [{42,
        %Geo.Geometry{coordinates: [30.0, -90.0], srid: 4326, type: :point}}]}}
  ```