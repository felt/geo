defmodule Geo.LineString do
  @moduledoc """
  Defines the LineString struct. Implements the Ecto.Type behaviour
  """

  alias Geo.Config

  @type t :: %Geo.LineString{coordinates: [{number, number}], srid: integer}
  defstruct coordinates: [], srid: nil

  if Code.ensure_loaded?(Ecto.Type) do
    @behaviour Ecto.Type

    def type, do: :geometry

    def blank?(_), do: false

    def load(%Geo.LineString{} = line_string), do: {:ok, line_string}
    def load(_), do: :error

    def dump(%Geo.LineString{} = line_string), do: {:ok, line_string}
    def dump(_), do: :error

    def cast(%Geo.LineString{} = line_string), do: {:ok, line_string}

    def cast(%{"type" => "LineString", "coordinates" => _} = line_string),
      do: {:ok, Geo.JSON.decode(line_string)}

    def cast(line_string) when is_binary(line_string) do
      {:ok, Config.json_library().decode!(line_string) |> Geo.JSON.decode()}
    end

    def cast(_), do: :error
  end
end
