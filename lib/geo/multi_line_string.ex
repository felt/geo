defmodule Geo.MultiLineString do

  @moduledoc """
  Defines the MultiLineString struct. Implements the Ecto.Type behaviour
  """

  @type t :: %Geo.MultiLineString{ coordinates: [[{number, number}]], srid: integer }
  @behaviour Ecto.Type
  defstruct coordinates: [], srid: nil

  def type, do: :geometry

  def blank?(_), do: false

  def load(%Geo.MultiLineString{} = multi_line_string), do: {:ok, multi_line_string}
  def load(_), do: :error

  def dump(%Geo.MultiLineString{} = multi_line_string), do: {:ok, multi_line_string}
  def dump(_), do: :error

  def cast(%Geo.MultiLineString{} = multi_line_string), do: {:ok, multi_line_string}
  def cast(multi_line_string) when is_map(multi_line_string), do: { :ok, Geo.JSON.decode(multi_line_string) }
  def cast(multi_line_string) when is_binary(multi_line_string), do: { :ok, Geo.JSON.decode(multi_line_string) }
  def cast(_), do: :error

end