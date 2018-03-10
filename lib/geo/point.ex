defmodule Geo.Point do
  @moduledoc """
  Defines the Point struct. Implements the Ecto.Type behaviour
  """

  alias Geo.Config

  @type t :: %Geo.Point{coordinates: {number, number}, srid: integer}
  defstruct coordinates: {0, 0}, srid: nil

  if Code.ensure_loaded?(Ecto.Type) do
    @behaviour Ecto.Type

    def type, do: :geometry

    def blank?(_), do: false

    def load(%Geo.Point{} = point), do: {:ok, point}
    def load(_), do: :error

    def dump(%Geo.Point{} = point), do: {:ok, point}
    def dump(_), do: :error

    def cast(%Geo.Point{} = point), do: {:ok, point}
    def cast(%{"type" => "Point", "coordinates" => _} = point), do: {:ok, Geo.JSON.decode(point)}

    def cast(point) when is_binary(point) do
      {:ok, Config.json_library().decode!(point) |> Geo.JSON.decode()}
    end

    def cast(_), do: :error
  end
end
