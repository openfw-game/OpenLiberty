@tool
class_name RWClumpInstance
extends Node3D

@export var clump: RWClump:
	set(value):
		if clump == value:
			return
		clump = value
		_rebuild()

@export var texture_dictionary: RWTextureDict:
	set(value):
		if texture_dictionary == value:
			return
		texture_dictionary = value
		_apply_textures()


## List of frames this clump instance owns
var frames: Array[Node3D] = []
## List of atomics this clump instance owns
var atomics: Array[MeshInstance3D] = []


func _rebuild() -> void:
	for frame in frames:
		# Freeing the parent frames should also free the atomics.
		frame.queue_free()
	frames.clear()
	atomics.clear()

	for frame in clump.frames:
		var node := Node3D.new()
		node.transform = frame.transform

		if frame.parent_index != -1:
			frames[frame.parent_index].add_child(node)
		else:
			add_child(node)
		frames.append(node)

	for atomic in clump.atomics:
		var instance := MeshInstance3D.new()
		instance.mesh = clump.geometries[atomic.geometry_index]

		frames[atomic.frame_index].add_child(instance)
		atomics.append(instance)

	_apply_textures()


func _apply_textures() -> void:
	if texture_dictionary == null:
		return

	for atomic in atomics:
		var mesh: ArrayMesh = atomic.mesh
		if mesh == null:
			continue
		for i in mesh.get_surface_count():
			var material: RWMaterial = mesh.surface_get_material(i)
			var texture := texture_dictionary.get_texture(material.texture_name)
			if texture != null:
				material.texture = texture
			var mask := texture_dictionary.get_texture(material.mask_name)
			if mask != null:
				material.mask = mask
