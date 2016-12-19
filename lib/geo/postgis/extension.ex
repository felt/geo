if Code.ensure_loaded?(Postgrex.Extension) do

  defmodule Geo.PostGIS.Extension do
    @behaviour Postgrex.Extension

    @moduledoc """
    PostGIS extension for Postgrex. Supports Geometry and Geography data types

        opts = [hostname: "localhost", username: "postgres", database: "geo_postgrex_test",
        types: Geo.PostGIS.PostgrexTypes ]

        [hostname: "localhost", username: "postgres", database: "geo_postgrex_test",
         types: Geo.PostGIS.PostgrexTypes]

        {:ok, pid} = Postgrex.Connection.start_link(opts)
        {:ok, #PID<0.115.0>}

        geo = %Geo.Point{coordinates: {30, -90}, srid: 4326}
        %Geo.Point{coordinates: {30, -90}, srid: 4326}

        {:ok, _} = Postgrex.Connection.query(pid, "CREATE TABLE point_test (id int, geom geometry(Point, 4326))")
        {:ok, %Postgrex.Result{columns: nil, command: :create_table, num_rows: 0, rows: nil}}

        {:ok, _} = Postgrex.Connection.query(pid, "INSERT INTO point_test VALUES ($1, $2)", [42, geo])
        {:ok, %Postgrex.Result{columns: nil, command: :insert, num_rows: 1, rows: nil}}

        Postgrex.Connection.query(pid, "SELECT * FROM point_test")
        {:ok, %Postgrex.Result{columns: ["id", "geom"], command: :select, num_rows: 1,
        rows: [{42, %Geo.Point{coordinates: {30.0, -90.0}, srid: 4326}}]}}

    """
    def init(opts) do
      Keyword.get(opts, :decode_binary, :reference)
    end


    def matching(_) do
      [type: "geometry", type: "geography"]
    end

    def format(_) do
      :text
    end

    def encode(_opts) do
      quote location: :keep do
        %x{} = geom when x in [Geo.GeometryCollection, Geo.LineString, Geo.MultiLineString, Geo.MultiPoint, Geo.MultiPolygon, Geo.Point, Geo.Polygon] ->
          data = Geo.WKT.encode(geom)
          [<<IO.iodata_length(data) :: int32>> | data]
      end
    end

    def decode(:reference) do
      quote location: :keep do
        <<len :: int32, wkb :: binary-size(len)>> ->
          Geo.WKB.decode(wkb)
      end
    end
    def decode(:copy) do
      quote location: :keep do
        <<len :: int32, wkb :: binary-size(len)>> ->
          Geo.WKB.decode(:binary.copy(wkb))
      end
    end
  end

end
