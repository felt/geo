defmodule Geo.Ecto.Test do
  use ExUnit.Case, async: true
  use Ecto.Migration
  import Ecto.Query

  defmodule Repo do
    use Ecto.Repo,
      otp_app: :geo,
      adapter: Ecto.Adapters.Postgres

  end

  defmodule Location do
    use Ecto.Model

    schema "locations" do
      field :name,           :string
      field :geom,           Geo.MultiPolygon
    end
  end

  setup context do
    {:ok, _} = Repo.start_link()
    {:ok, _} = Ecto.Migration.Runner.start_link(Repo, :forward, false)

    on_exit fn ->
      try do
        Ecto.Migration.Runner.stop()
        Repo.stop()
      catch
        :exit, _ -> :ok
      end
    end

  end

  test "query multipoint" do
    if exists? table(:locations) do
      drop table(:locations)     
    end

    create table(:locations) do
      add :name,     :string
      add :geom,     :geometry
    end

    geom = Geo.WKB.decode("0106000020E6100000010000000103000000010000000F00000091A1EF7505D521C0F4AD6182E481424072B3CE92FED421C01D483CDAE281424085184FAEF7D421C0CB159111E1814240E1EBD7FBF8D421C0D421F7C8DF814240AD111315FFD421C0FE1F21C0DE81424082A0669908D521C050071118DE814240813C5E700FD521C0954EEF97DE814240DC889FA815D521C0B3382182E08142400148A81817D521C0E620D22BE2814240F1E95BDE19D521C08BD53852E3814240F81699E217D521C05B35D7DCE4814240B287C8D715D521C0336338FEE481424085882FB90FD521C0FEF65484E5814240A53E1E460AD521C09A0EA286E581424091A1EF7505D521C0F4AD6182E4814240")

    location = Repo.insert(%Location{name: "hello", geom: geom})

    query = from location in Location, limit: 5, select: location

    results = Repo.all(query)

    assert geom == hd(results).geom

    drop table(:locations)
  end

end