defmodule Geo.Ecto.Test do
  use ExUnit.Case, async: true
  use Ecto.Migration
  import Ecto.Query
  import Geo.PostGIS

  @multipoint_wkb "0106000020E6100000010000000103000000010000000F00000091A1EF7505D521C0F4AD6182E481424072B3CE92FED421C01D483CDAE281424085184FAEF7D421C0CB159111E1814240E1EBD7FBF8D421C0D421F7C8DF814240AD111315FFD421C0FE1F21C0DE81424082A0669908D521C050071118DE814240813C5E700FD521C0954EEF97DE814240DC889FA815D521C0B3382182E08142400148A81817D521C0E620D22BE2814240F1E95BDE19D521C08BD53852E3814240F81699E217D521C05B35D7DCE4814240B287C8D715D521C0336338FEE481424085882FB90FD521C0FEF65484E5814240A53E1E460AD521C09A0EA286E581424091A1EF7505D521C0F4AD6182E4814240"

  defmodule Repo do
    use Ecto.Repo, otp_app: :geo
  end

  defmodule Location do
    use Ecto.Schema

    schema "locations" do
      field :name,           :string
      field :geom,           Geo.MultiPolygon
    end
  end

  defmodule Geographies do
    use Ecto.Schema

    schema "geographies" do
      field :name,           :string
      field :geom,           Geo.Point
    end
  end

  defmodule LocationMulti do
    use Ecto.Schema

    schema "location_multi" do
      field :name,           :string
      field :geom,           Geo.Geometry
    end
  end

  setup _ do
    {:ok, pid} = Postgrex.start_link(Geo.Test.Helper.opts)
    {:ok, _} = Postgrex.query(pid, "DROP TABLE IF EXISTS locations, geographies, location_multi", [])
    {:ok, _} = Postgrex.query(pid, "CREATE TABLE locations (id serial primary key, name varchar, geom geometry(MultiPolygon))", [])
    {:ok, _} = Postgrex.query(pid, "CREATE TABLE geographies (id serial primary key, name varchar, geom geography(Point))", [])
    {:ok, _} = Postgrex.query(pid, "CREATE TABLE location_multi (id serial primary key, name varchar, geom geometry)", [])

    {:ok, _} = Repo.start_link()

    :ok

  end

  test "query multipoint" do
    geom = Geo.WKB.decode(@multipoint_wkb)

    Repo.insert(%Location{name: "hello", geom: geom})
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

  test "query transform" do
    geom = Geo.WKB.decode(@multipoint_wkb)

    Repo.insert(%Location{name: "hello", geom: geom})

    query = from location in Location, limit: 1, select: st_transform(location.geom, 3452)
    results = Repo.one(query)

    assert results = %Geo.MultiPolygon{coordinates: [[[{25490891.87425425, 11454760.39286618}, {25490915.72503668, 11454756.622236678}, {25490940.521944612, 11454751.789483352},
               {25490947.78999233, 11454739.051259525}, {25490945.122736573, 11454721.31933375}, {25490933.894902337, 11454701.716498088},
               {25490918.661036905, 11454695.809277687}, {25490894.034267686, 11454702.74008471}, {25490879.34116009, 11454714.62020763}, {25490866.177257963, 11454720.207039082},
               {25490858.15628082, 11454736.123776026}, {25490860.643045224, 11454740.24201736}, {25490867.112289257, 11454753.703846656},
               {25490876.247982353, 11454761.838036865}, {25490891.87425425, 11454760.39286618}]]], srid: 3452}
  end

  test "query distance" do
    geom = Geo.WKB.decode(@multipoint_wkb)

    Repo.insert(%Location{name: "hello", geom: geom})

    query = from location in Location, limit: 5, select: st_distance(location.geom, ^geom)
    results = Repo.one(query)

    assert results == 0
  end

  test "query sphere distance" do
    geom = Geo.WKB.decode(@multipoint_wkb)

    Repo.insert(%Location{name: "hello", geom: geom})

    query = from location in Location, limit: 5, select: st_distance_sphere(location.geom, ^geom)
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

    Repo.insert(%Geographies{name: "hello", geom: geom})
    query = from location in Geographies, limit: 5, select: location
    results = Repo.all(query)

    assert geom == hd(results).geom
  end

  test "cast point" do
    geom = %Geo.Point{ coordinates: {30, -90}, srid: 4326}

    Repo.insert(%Geographies{name: "hello", geom: geom})
    query = from location in Geographies, limit: 5, select: location
    results = Repo.all(query)

    result = hd(results)

    json = Geo.JSON.encode(%Geo.Point{ coordinates: {31, -90}, srid: 4326})

    changeset = Ecto.Changeset.cast(result, %{title: "Hello", geom: json}, ~w(name geom), ~w())
    assert changeset.changes == %{geom: %Geo.Point{coordinates: {31, -90}, srid: 4326}}
  end

  test "cast point from map" do
    geom = %Geo.Point{ coordinates: {30, -90}, srid: 4326}

    Repo.insert(%Geographies{name: "hello", geom: geom})
    query = from location in Geographies, limit: 5, select: location
    results = Repo.all(query)

    result = hd(results)

    json = %{ "type" => "Point",
              "crs" => %{ "type" => "name", "properties" => %{"name" => "EPSG4326" } },
              "coordinates" => [31, -90] }

    changeset = Ecto.Changeset.cast(result, %{title: "Hello", geom: json}, ~w(name geom), ~w())
    assert changeset.changes == %{geom: %Geo.Point{coordinates: {31, -90}, srid: 4326}}
  end

  test "order by distance" do
    geom1 = %Geo.Point{ coordinates: {30, -90}, srid: 4326}
    geom2 = %Geo.Point{ coordinates: {30, -91}, srid: 4326}
    geom3 = %Geo.Point{ coordinates: {60, -91}, srid: 4326}

    Repo.insert(%Geographies{name: "there", geom: geom2})
    Repo.insert(%Geographies{name: "here",  geom: geom1})
    Repo.insert(%Geographies{name: "way over there",  geom: geom3})

    query = from location in Geographies, limit: 5, select: location, order_by: st_distance(location.geom, ^geom1)
    assert ["here", "there", "way over there"] ==
      Repo.all(query)
      |> Enum.map(fn x -> x.name end)
  end


  defimpl Ecto.DataType, for: Map do
    def cast(%{"latitude" => lat, "longitude" => long}, Geo.Point) do
      {:ok, %Geo.Point{coordinates: {lat, long}, srid: 4326}}
    end
    def cast(_, _), do: :error
  end


  test "defimpl Ecto.DataType" do
    geom = %Geo.Point{ coordinates: {30, -90}, srid: 4326}

    Repo.insert(%Geographies{name: "hello", geom: geom})
    query = from location in Geographies, limit: 5, select: location
    results = Repo.all(query)

    result = hd(results)

    changeset = Ecto.Changeset.cast(result, %{title: "Hello", geom: %{"latitude" => 31, "longitude" => -90 }}, ~w(name geom), ~w())
    assert changeset.changes == %{geom: %Geo.Point{coordinates: {31, -90}, srid: 4326}}
  end


  test "insert multiple geometry types" do
    geom1 = %Geo.Point{ coordinates: {30, -90}, srid: 4326}
    geom2 = %Geo.LineString{ coordinates: [{30, -90}, {30, -91}], srid: 4326}

    Repo.insert(%LocationMulti{name: "hello point", geom: geom1})
    Repo.insert(%LocationMulti{name: "hello line", geom: geom2})
    query = from location in LocationMulti, select: location
    [m1, m2] = Repo.all(query)

    assert m1.geom == geom1
    assert m2.geom == geom2
  end

end
