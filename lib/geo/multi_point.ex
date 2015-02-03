defmodule Geo.MultiPoint do

  @moduledoc """
  Defines the MultiPoint struct. Implements the Ecto.Type behaviour
  """

  @type t :: %Geo.MultiPoint{ coordinates: [{number, number}], srid: integer }
  @behaviour Ecto.Type
  defstruct coordinates: [], srid: nil

  def type, do: :geometry

  def blank?(_), do: false

  def load(%Geo.MultiPoint{} = multi_point), do: {:ok, multi_point}
  def load(_), do: :error

  def dump(%Geo.MultiPoint{} = multi_point), do: {:ok, multi_point}
  def dump(_), do: :error

  def cast(%Geo.MultiPoint{} = multi_point), do: {:ok, multi_point}
  def cast(_), do: :error

end