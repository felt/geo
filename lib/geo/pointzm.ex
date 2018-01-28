defmodule Geo.PointZM do
  @moduledoc """
  Defines the PointZM struct. Implements the Ecto.Type behaviour
  """

  @type t :: %Geo.PointZM{coordinates: {number, number, number, number}, srid: integer}
  defstruct coordinates: {0, 0, 0, 0}, srid: nil

  if Code.ensure_loaded?(Ecto.Type) do
    @behaviour Ecto.Type

    def type, do: :geometry

    def blank?(_), do: false

    def load(%Geo.PointZM{} = point), do: {:ok, point}
    def load(_), do: :error

    def dump(%Geo.PointZM{} = point), do: {:ok, point}
    def dump(_), do: :error

    def cast(%Geo.PointZM{} = point), do: {:ok, point}
    def cast(%{"type" => _, "coordinates" => _} = point), do: {:ok, Geo.JSON.decode(point)}

    if Code.ensure_loaded?(Poison) do
      def cast(point) when is_binary(point), do: {:ok, Poison.decode!(point) |> Geo.JSON.decode()}
    end

    def cast(_), do: :error
  end
end
