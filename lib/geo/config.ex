defmodule Geo.Config do
  def json_library do
    Application.get_env(:geo, :json_library, Poison)
  end
end
