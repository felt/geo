defmodule Geo.WKT do
  alias Geo.Geometry

  def encode(Geometry[type: :point, coordinates: coordinates]) do
    "POINT(#{Enum.join(coordinates, " ")})"
  end

  def encode(Geometry[type: :line_string, coordinates: coordinates]) do
    s = Enum.map(coordinates, fn(x) -> Enum.join(x, " ") end)
    "LINESTRING(#{Enum.join(s, ", ")})"
  end

  def encode(Geometry[type: :polygon, coordinates: coordinates]) do
    s = Enum.map(coordinates, fn(x) -> Enum.join(Enum.map(x, fn(y) -> Enum.join(y," ") end), ", ") end)
    "POLYGON((#{Enum.join(s, "),(")}))"
  end

  def decode(wkt) do
      String.split(wkt, "(", [global: false, trim: true])
      |> list_to_tuple
      |> _decode
  end

  defp _decode({"POINT", coordinates}) do
    coordinates = String.replace(coordinates, ")","")
    Geometry.new(type: :point, coordinates: create_point(coordinates))
  end

  defp _decode({"LINESTRING", coordinates}) do
    coordinates = String.replace(coordinates, ")","")
    Geometry.new(type: :line_string, coordinates: create_line_string(coordinates))
  end

  defp _decode({"POLYGON", coordinates}) do
    coordinates = String.split(coordinates, "),(")
    |> Enum.map(fn(x) -> String.replace(x, ")", "") |> String.replace("(", "") end)

    Geometry.new(type: :polygon, coordinates: Enum.map(coordinates, &create_line_string(&1)) )
  end

  defp create_point(coordinates) do
    String.strip(coordinates) |> String.split |> Enum.map(fn(x) -> binary_to_number(x) end)
  end

  defp create_line_string(coordinates) do
    String.split(coordinates,",") |> Enum.map(fn(y) -> create_point(y) end)
  end

  defp binary_to_number(binary) do
    if String.contains?(binary,"."), do: binary_to_float(binary), else: binary_to_integer(binary)
  end
end
