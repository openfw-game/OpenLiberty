class_name ItemPlacement
extends RefCounted

var instances: Array[Instance] = []


static func open(path: String) -> ItemPlacement:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Could not open %s: %s" % [path, error_string(FileAccess.get_open_error())])
		return null

	var defs := ItemPlacement.new()
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
			"inst":
				if defs._parse_instance(tokens) != OK:
					return null

	return defs


func _parse_instance(tokens: PackedStringArray) -> Error:
	var position := Vector3(tokens[2].to_float(), tokens[3].to_float(), tokens[4].to_float())
	var scale := Vector3(tokens[5].to_float(), tokens[6].to_float(), tokens[7].to_float())
	var rotation := Quaternion(
		tokens[8].to_float(),
		tokens[9].to_float(),
		tokens[10].to_float(),
		# GTA 3 uses left-handed quaternions. Rockstar why do you do this to me.
		-tokens[11].to_float(),
	)

	var instance := Instance.new()
	instance.object_id = tokens[0].to_int()
	instance.transform = Transform3D(Basis(rotation).scaled(scale), position)
	instances.append(instance)
	return OK


class Instance:
	var object_id: int
	var transform: Transform3D
