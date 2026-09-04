class_name ItemDefinition
extends RefCounted

var objects: Dictionary[int, ObjectDef] = {}
var lod_map: Dictionary[String, ObjectDef] = {}


static func open(path: String) -> ItemDefinition:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Could not open %s: %s" % [path, error_string(FileAccess.get_open_error())])
		return null

	var defs := ItemDefinition.new()
	var section := ""
	while not file.eof_reached():
		var tokens := PackedStringArray()
		for token in file.get_line().split(",", false):
			tokens.append(token.strip_edges())
		if tokens.size() == 0:
			continue
		if tokens[0].begins_with("#"):
			continue

		if tokens.size() == 1:
			if tokens[0] == "end":
				section = ""
				continue
			section = tokens[0]
			continue

		match section:
			"objs":
				if defs._parse_object(tokens) != OK:
					return null
			"2dfx":
				if defs._parse_2dfx(tokens) != OK:
					return null

	return defs


func _parse_object(tokens: PackedStringArray) -> Error:
	var obj := ObjectDef.new()
	obj.model_name = tokens[1]
	obj.txd_name = tokens[2]

	if tokens.size() > 5:
		obj.draw_distances.append(tokens[4].to_float())
	if tokens.size() > 6:
		obj.draw_distances.append(tokens[5].to_float())
	if tokens.size() > 7:
		obj.draw_distances.append(tokens[6].to_float())

	obj.flags = tokens[tokens.size() - 1].to_int()
	objects[tokens[0].to_int()] = obj
	if not obj.is_lod and obj.model_name.length() >= 4:
		lod_map[("LOD" + obj.model_name.substr(3)).to_lower()] = obj
	return OK




func _parse_2dfx(tokens: PackedStringArray) -> Error:
	var parent_id := tokens[0].to_int()
	if not objects.has(parent_id):
		return OK

	var fx_type := tokens[8].to_int()
	match fx_type:
		0:
			var light := Light2DFX.new()
			light.position = Vector3(tokens[1].to_float(), tokens[2].to_float(), tokens[3].to_float())
			light.color = Color(
				tokens[4].to_float() / 255.0,
				tokens[5].to_float() / 255.0,
				tokens[6].to_float() / 255.0,
			)
			light.view_distance = tokens[11].to_float()
			light.outer_range = tokens[12].to_float()
			light.corona_size = tokens[13].to_float()
			light.inner_range = tokens[14].to_float()
			light.shadow_intensity = tokens[15].to_int()
			light.flash = tokens[16].to_int()
			objects[parent_id].lights.append(light)
		_:
			pass
	return OK


class ObjectDef:
	enum {
		DO_NOT_FADE = 0x02,
		DRAW_LAST = 0x04,
		ADDITIVE = 0x08,
		IS_SUBWAY = 0x10,
		IGNORE_LIGHTING = 0x20,
		NO_ZBUFFER_WRITE = 0x40,
	}

	var model_name: String
	var txd_name: String
	var draw_distances: PackedFloat32Array
	var flags: int
	var lights: Array[Light2DFX] = []

	## Whether this is a LOD model. GTA3 names LOD models by replacing the
	## base model's first three characters with "LOD". (The "IslandLOD*"
	## silhouette models are a special case handled separately, not by distance.)
	var is_lod: bool:
		get:
			return model_name.begins_with("LOD")

	## Whether this is a "big building". Big buildings only start rendering at
	## 300 units from the camera, regardless of their draw distance.
	var is_big_building: bool:
		get:
			return draw_distances[0] >= 300.0


class Light2DFX:
	var position: Vector3
	var color: Color
	var view_distance: float
	var outer_range: float
	var corona_size: float
	var inner_range: float
	var shadow_intensity: int
	var flash: int
