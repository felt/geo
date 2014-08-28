defmodule Geo.JSON do
	alias Geo.Geometry


	def decode(geo_json) do
		decoded_json = JSEX.decode!(geo_json)

		if(Dict.has_key?(decoded_json, "geometries")) do
			Enum.map(decoded_json["geometries"], fn(x) -> %Geometry{ type: decode_type(x["type"]), coordinates: x["coordinates"] }	  end)
		else
			%Geometry{ type: decode_type(decoded_json["type"]), coordinates: decoded_json["coordinates"] }
		end
	end


	def encode(geom) when is_list(geom) do
		JSEX.encode!([type: "GeometryCollection", geometries: Enum.map(geom, fn(x) -> [type: encode_type(x.type), coordinates: x.coordinates] end)])
	end

	def encode(geom) do
		JSEX.encode!([type: encode_type(geom.type), coordinates: geom.coordinates])
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
