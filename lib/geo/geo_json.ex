defmodule Geo.JSON do
	alias Geo.Geometry


	def decode(geo_json) do
		decoded_json = JSON.decode!(geo_json)
		Geometry.new(type: decode_type(decoded_json["type"]), coordinates: decoded_json["coordinates"])
	end


	def encode(geom) do
		JSON.encode!([type: encode_type(geom.type), coordinates: geom.coordinates])	
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
			_ ->
				:multi_polygon
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
			_ ->
				"MultiPolygon"
		end
	end
end