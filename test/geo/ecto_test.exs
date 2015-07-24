defmodule Geo.Ecto.Test do
  use ExUnit.Case, async: true
  use Ecto.Migration
  import Ecto.Query
  import Geo.PostGIS

  @multipoint_wkb "0106000020E6100000010000000103000000010000000F00000091A1EF7505D521C0F4AD6182E481424072B3CE92FED421C01D483CDAE281424085184FAEF7D421C0CB159111E1814240E1EBD7FBF8D421C0D421F7C8DF814240AD111315FFD421C0FE1F21C0DE81424082A0669908D521C050071118DE814240813C5E700FD521C0954EEF97DE814240DC889FA815D521C0B3382182E08142400148A81817D521C0E620D22BE2814240F1E95BDE19D521C08BD53852E3814240F81699E217D521C05B35D7DCE4814240B287C8D715D521C0336338FEE481424085882FB90FD521C0FEF65484E5814240A53E1E460AD521C09A0EA286E581424091A1EF7505D521C0F4AD6182E4814240"

  defmodule Repo do
    use Ecto.Repo,
      otp_app: :geo

  end

  defmodule Location do
    use Ecto.Model

    schema "locations" do
      field :name,           :string
      field :geom,           Geo.MultiPolygon
    end
  end

  defmodule Geographies do
    use Ecto.Model

    schema "geographies" do
      field :name,           :string
      field :geom,           Geo.Point
    end
  end

  setup context do
    opts = [hostname: "localhost", 
    username: "postgres", database: "geo_postgrex_test",
    extensions: [{Geo.PostGIS.Extension, library: Geo}]]

    {:ok, pid} = Postgrex.Connection.start_link(opts)
    {:ok, _} = Postgrex.Connection.query(pid, "DROP TABLE IF EXISTS locations, geographies", [])
    {:ok, _} = Postgrex.Connection.query(pid, "CREATE TABLE locations (id serial primary key, name varchar, geom geometry(MultiPolygon))", [])
    {:ok, _} = Postgrex.Connection.query(pid, "CREATE TABLE geographies (id serial primary key, name varchar, geom geography(Point))", [])

    {:ok, _} = Repo.start_link()

    :ok

  end

  test "query multipoint" do
    geom = Geo.WKB.decode(@multipoint_wkb)

    location = Repo.insert(%Location{name: "hello", geom: geom})
    query = from location in Location, limit: 5, select: location
    results = Repo.all(query)

    assert geom == hd(results).geom
  end

  test "query area" do
    geom = Geo.WKB.decode(@multipoint_wkb)

    Repo.insert(%Location{name: "hello", geom: geom})

    query = from location in Location, limit: 5, select: st_area(location.geom)
    results = Repo.all(query)

    assert is_number(hd(results))
  end

  test "query distance" do
    geom = Geo.WKB.decode(@multipoint_wkb)

    Repo.insert(%Location{name: "hello", geom: geom})

    query = from location in Location, limit: 5, select: st_distance(location.geom, ^geom)
    results = Repo.one(query)

    assert results == 0
  end

  test "example" do
    geom = Geo.WKB.decode(@multipoint_wkb)
    Repo.insert(%Location{name: "hello", geom: geom})


    defmodule Example do
      import Ecto.Query
      import Geo.PostGIS

      def example_query(geom) do
        from location in Location, select: st_distance(location.geom, ^geom)  
      end

    end 

    query = Example.example_query(geom)
    results = Repo.one(query)
    assert results == 0
  end

  test "geography" do
    geom = %Geo.Point{ coordinates: {30, -90}, srid: 4326}

    geographies = Repo.insert(%Geographies{name: "hello", geom: geom})
    query = from location in Geographies, limit: 5, select: location
    results = Repo.all(query)

    assert geom == hd(results).geom
  end

  test "cast point" do
    geom = %Geo.Point{ coordinates: {30, -90}, srid: 4326}

    geographies = Repo.insert(%Geographies{name: "hello", geom: geom})
    query = from location in Geographies, limit: 5, select: location
    results = Repo.all(query)

    result = hd(results)

    json = Geo.JSON.encode(%Geo.Point{ coordinates: {31, -90}, srid: 4326})

    changeset = Ecto.Changeset.cast(result, %{title: "Hello", geom: json}, ~w(name geom), ~w())  
    assert changeset.changes == %{geom: %Geo.Point{coordinates: {31, -90}, srid: 4326}}
  end

  test "cast point from map" do
    geom = %Geo.Point{ coordinates: {30, -90}, srid: 4326}

    geographies = Repo.insert(%Geographies{name: "hello", geom: geom})
    query = from location in Geographies, limit: 5, select: location
    results = Repo.all(query)

    result = hd(results)

    json = %{ "type" => "Point", 
              "crs" => %{ "type" => "name", "properties" => %{"name" => "EPSG4326" } },
              "coordinates" => [31, -90] }

    changeset = Ecto.Changeset.cast(result, %{title: "Hello", geom: json}, ~w(name geom), ~w())  
    assert changeset.changes == %{geom: %Geo.Point{coordinates: {31, -90}, srid: 4326}}
  end
end