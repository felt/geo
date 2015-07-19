defmodule Geo.PostGIS.Extension do
  alias Postgrex.TypeInfo

  @behaviour Postgrex.Extension

  @moduledoc """
  PostGIS extension for Postgrex. Supports Geometry and Geography data types

      opts = [hostname: "localhost", username: "postgres", database: "geo_postgrex_test",
      extensions: [{Geo.PostGIS.Extension, library: Geo}] ]

      [hostname: "localhost", username: "postgres", database: "geo_postgrex_test",
       extensions: [{Geo.PostGIS.Extension, library: Geo}]]

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
  def init(_parameters, _opts) do
    :ok
  end

  def matching(_) do
    [type: "geometry", type: "geography"]
  end

  def format(_) do
    :text
  end

  def encode(%TypeInfo{type: "geometry"}, geom, _state, _library) do
    Geo.WKT.encode(geom)
  end

  def encode(%TypeInfo{type: "geography"}, geom, _state, _library) do
    Geo.WKT.encode(geom)
  end

  def decode(%TypeInfo{type: "geometry"}, wkb, _state, _library) do
    Geo.WKB.decode(wkb)
  end

  def decode(%TypeInfo{type: "geography"}, wkb, _state, _library) do
    Geo.WKB.decode(wkb)
  end
end