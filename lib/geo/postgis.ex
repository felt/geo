defmodule Geo.PostGIS do
  alias Postgrex.TypeInfo

  @moduledoc """
  Encoder, Decoder, and Formatter to be used with Postgrex for PostGIS data types

      opts = [hostname: "localhost", username: "postgres", database: "geo_postgrex_test",
      encoder: &Geo.PostGIS.encoder/3, decoder: &Geo.PostGIS.decoder/4,
      formatter: &Geo.PostGIS.formatter/1 ]

      [hostname: "localhost", username: "postgres", database: "geo_postgrex_test",
       encoder: &Geo.PostGIS.encoder/3, decoder: &Geo.PostGIS.decoder/4,
       formatter: &Geo.PostGIS.formatter/1]

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

  def decoder(%TypeInfo{sender: "geometry", type: "geometry"}, _format , _, value) do
    Geo.WKB.decode(value)
  end

  def decoder(%TypeInfo{}, _format, default, bin) do
    default.(bin)
  end

  def encoder(%TypeInfo{sender: "geometry", type: "geometry"}, _, value) do
    Geo.WKT.encode(value)
  end

  def encoder(%TypeInfo{}, default, value) do
    default.(value)
  end

  def formatter(%TypeInfo{sender: "geometry"}), do: :text
  def formatter(%TypeInfo{}), do: nil
end