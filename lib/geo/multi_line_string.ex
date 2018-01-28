defmodule Geo.MultiLineString do

  @moduledoc """
  Defines the MultiLineString struct. Implements the Ecto.Type behaviour
  """

  @type t :: %Geo.MultiLineString{ coordinates: [[{number, number}]], srid: integer }
  defstruct coordinates: [], srid: nil

  if Code.ensure_loaded?(Ecto.Type) do
    @behaviour Ecto.Type

    def type, do: :geometry

    def blank?(_), do: false

    def load(%Geo.MultiLineString{} = multi_line_string), do: {:ok, multi_line_string}
    def load(_), do: :error

    def dump(%Geo.MultiLineString{} = multi_line_string), do: {:ok, multi_line_string}
    def dump(_), do: :error

    def cast(%Geo.MultiLineString{} = multi_line_string), do: {:ok, multi_line_string}
    def cast(%{"type" => "MultiLineString", "coordinates" => _} = multi_line_string), do: { :ok, Geo.JSON.decode(multi_line_string) }

    if Code.ensure_loaded?(Poison) do
      def cast(multi_line_string) when is_binary(multi_line_string), do: { :ok, Poison.decode!(multi_line_string) |> Geo.JSON.decode }
    end

    def cast(_), do: :error
  end

end
