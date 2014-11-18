defmodule Geo.JSON do
	alias Geo.Geometry
	use Jazz

  @moduledoc """
  Converts to and from GeoJSON
  
  ```
  json = "{ \"type\": \"Point\", \"coordinates\": [100.0, 0.0] }"
  geom = Geo.JSON.decode(json)
  Geo.Geometry[type: :point, coordinates: [100.0, 0.0], srid: nil]

	Geo.JSON.encode(geom)
  "{ \"type\": \"Point\", \"coordinates\": [100.0, 0.0] }"
  ```
  """

	@doc """
	Takes a GeoJSON string and returns a Geo.Geometry struct or list of Geo.Geometry
	"""
	def decode(geo_json) do
		decoded_json = JSON.decode!(geo_json, keys: :atoms)

		case Map.has_key?(decoded_json, :geometries) do
			true ->
				Enum.map(decoded_json.geometries, 
					fn(x) -> %Geometry{ type: decode_type(x.type), coordinates: x.coordinates }	  end)
			false ->
				%Geometry{ type: decode_type(decoded_json.type), coordinates: decoded_json.coordinates }
		end 
	end


	@doc """
	Takes a Geo.Geometry struct or a list of Geo.Geometry and returns a geoJSON string
	"""
	def encode(geom) when is_list(geom) do
		JSON.encode!(%{
			type: "GeometryCollection", 
			geometries: Enum.map(geom, fn(x) -> %{ type: encode_type(x.type), coordinates: x.coordinates } end)
		})
	end

	def encode(geom) do
		JSON.encode!(%{ type: encode_type(geom.type), coordinates: geom.coordinates })
	end

	defp decode_type(geo_json_type) do
		case geo_json_type do
			"Point" ->
				:point
			"LineString" ->
				:line_string
			"Polygon" ->
				:polygon
			"MultiPoint" ->
				:multi_point
			"MultiLineString" ->
				:multi_line_string
			"MultiPolygon" ->
				:multi_polygon
			_ ->
				:geometry_collection
		end
	end

	defp encode_type(geom_type) do
		case geom_type do
			:point ->
				"Point"
			:line_string ->
				"LineString"
			:polygon ->
				"Polygon"
			:multi_point ->
				"MultiPoint"
			:multi_line_string ->
				"MultiLineString"
			:multi_polygon ->
				"MultiPolygon"
			_ ->
				"GeometryCollection"
		end
	end
end
