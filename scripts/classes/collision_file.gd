class_name CollisionFile
extends RefCounted

var models: Dictionary[String, CollisionModel] = {}


static func open(path: String) -> CollisionFile:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Could not open %s: %s" % [path, error_string(FileAccess.get_open_error())])
		return null

	var col := CollisionFile.new()
	while file.get_position() < file.get_length():
		var model := CollisionModel.new(file)
		col.models[model.model_name.to_lower()] = model

	return col


class CollisionModel:
	var model_name: String
	var model_id: int
	var tbounds: TBounds
	var spheres: Array[TSphere] = []
	var boxes: Array[TBox] = []
	var mesh_faces: PackedVector3Array

	func _init(file: FileAccess):
		assert(file.get_buffer(4).get_string_from_ascii() == "COLL")
		file.get_32()
		model_name = file.get_buffer(22).get_string_from_ascii()
		model_id = file.get_16()
		tbounds = TBounds.new(file)

		for i in file.get_32():
			spheres.append(TSphere.new(file))
		file.get_32()
		for i in file.get_32():
			boxes.append(TBox.new(file))

		var unsorted := PackedVector3Array()
		for i in file.get_32():
			unsorted.append(TVertex.new(file).position)

		mesh_faces = PackedVector3Array()
		for i in file.get_32():
			var face := TFace.new(file)
			mesh_faces.append(unsorted[face.a])
			mesh_faces.append(unsorted[face.b])
			mesh_faces.append(unsorted[face.c])


	class TBounds:
		var radius: float
		var center: Vector3
		var min: Vector3
		var max: Vector3

		func _init(file: FileAccess):
			radius = file.get_float()
			center = _read_vector3(file)
			min = _read_vector3(file)
			max = _read_vector3(file)

		static func _read_vector3(file: FileAccess) -> Vector3:
			return Vector3(file.get_float(), file.get_float(), file.get_float())


	class TSphere:
		var radius: float
		var center: Vector3
		var surface: TSurface

		func _init(file: FileAccess):
			radius = file.get_float()
			center = TBounds._read_vector3(file)
			surface = TSurface.new(file)


	class TBox:
		var min: Vector3
		var max: Vector3
		var surface: TSurface

		func _init(file: FileAccess):
			min = TBounds._read_vector3(file)
			max = TBounds._read_vector3(file)
			surface = TSurface.new(file)


	class TVertex:
		var position: Vector3

		func _init(file: FileAccess):
			position = TBounds._read_vector3(file)


	class TFace:
		var a: int
		var b: int
		var c: int
		var surface: TSurface

		func _init(file: FileAccess):
			a = file.get_32()
			b = file.get_32()
			c = file.get_32()
			surface = TSurface.new(file)


	class TSurface:
		var material: int
		var flag: int
		var brightness: int
		var light: int

		func _init(file: FileAccess):
			material = file.get_8()
			flag = file.get_8()
			brightness = file.get_8()
			light = file.get_8()