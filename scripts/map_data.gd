class_name MapData
extends RefCounted

const STATIC_LIGHTING_LAYER: int = 1 << 1

var objects: Dictionary[int, ItemDefinition.ObjectDef] = { }
var instances: Array[ItemPlacement.Instance] = []
var collisions: Dictionary[String, CollisionFile.CollisionModel] = { }
## Maps LOD model names (lowercase) to their base ObjectDef, built at IDE parse
## time by replacing the first three characters of each base name with "LOD".
##
## NOTE: The "IslandLOD*" models (IslandLODInd, IslandLODcomIND, IslandLODcomSUB,
## IslandLODsubIND, IslandLODsubCOM) are NOT covered by this convention.
## In GTA3 their visibility is hard-coded (CStreaming::RequestIslands) and driven
## by the player's current island level, not by distance. They need special-casing
## once zone/level parsing lands.
var lod_map: Dictionary[String, ItemDefinition.ObjectDef] = { }


static func open(path: String) -> MapData:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Could not open %s: %s" % [path, error_string(FileAccess.get_open_error())])
		return null

	var data := MapData.new()
	while not file.eof_reached():
		var tokens := file.get_line().split(" ", false)
		if tokens.size() == 0:
			continue
		if tokens[0].begins_with("#"):
			continue

		match tokens[0]:
			"IDE":
				var defs := ItemDefinition.open(NoCaseFS.resolve(GameManager.gta_path.path_join(
							tokens[1].replace("\\", "/")
						)))
				if defs == null:
					return null
				data.objects.merge(defs.objects)
				data.lod_map.merge(defs.lod_map)
			"IPL":
				var placements := ItemPlacement.open(NoCaseFS.resolve(GameManager.gta_path.path_join(
							tokens[1].replace("\\", "/")
						)))
				if placements == null:
					return null
				data.instances.append_array(placements.instances)
			"COLFILE":
				var col := CollisionFile.open(NoCaseFS.resolve(GameManager.gta_path.path_join(
						tokens[2].replace("\\", "/")
					)))
				if col == null:
					return null
				data.collisions.merge(col.models)
			_:
				push_warning("Unknown token: %s" % [tokens[0]])

	return data


func instantiate() -> Node3D:
	var root := Node3D.new()

	for instance in instances:
		var object: ItemDefinition.ObjectDef = objects.get(instance.object_id, null)
		if object == null:
			push_error("Instance references unknown object with ID %d" % instance.object_id)
			continue

		# TODO: IslandLOD visibility is level-driven (CStreaming::RequestIslands),
		# not distance-driven. Needs zone/level parsing before these can be placed.
		if object.model_name.begins_with("IslandLOD"):
			continue

		if object.flags & 0x40: # Ignore shadows
			continue

		var node := RWClumpInstance.new()
		node.transform = Utils.gta_to_godot(instance.transform)
		root.add_child(node)
		if _load_clump(node, object):
			_apply_object_flags(node, object)
			for atomic in node.atomics:
				atomic.visibility_range_end = object.draw_distances[0]
				if object.is_big_building and not object.is_lod:
					atomic.visibility_range_begin = 300.0

		if object.is_lod:
			var base: ItemDefinition.ObjectDef = lod_map.get(object.model_name.to_lower(), null)
			if base != null:
				for atomic in node.atomics:
					atomic.visibility_range_begin = base.draw_distances[0]
			continue

		var model: CollisionFile.CollisionModel = collisions.get(object.model_name.to_lower(), null)
		if model != null:
			_spawn_collision(node, model)

		for light in object.lights:
			_spawn_light(node, light)

	return root


func _load_clump(node: RWClumpInstance, object: ItemDefinition.ObjectDef) -> bool:
	var dff_path := ModelFS.resolve(object.model_name + ".dff")
	if dff_path.is_empty():
		return false
	var loaded := ResourceLoader.load(dff_path, "Resource", ResourceLoader.CACHE_MODE_REUSE) as RWClump
	if loaded == null:
		return false
	node.clump = loaded
	return true


func _apply_object_flags(node: RWClumpInstance, object: ItemDefinition.ObjectDef) -> void:
	for atomic in node.atomics:
		if object.flags & 0x20 == 0:
			atomic.layers = STATIC_LIGHTING_LAYER

		var mesh := atomic.mesh
		for surf_id in mesh.get_surface_count():
			var material := mesh.surface_get_material(surf_id) as RWMaterial
			if material == null:
				continue
			if object.flags & 0x08:
				material.blend_mode = RWMaterial.BlendMode.ADD


func _spawn_light(parent: Node3D, light: ItemDefinition.Light2DFX) -> void:
	var node := OmniLight3D.new()
	node.position = light.position
	node.light_color = light.color
	node.distance_fade_enabled = true
	node.distance_fade_begin = light.view_distance
	node.omni_range = light.outer_range
	node.shadow_opacity = float(light.shadow_intensity) / 40.0
	node.shadow_enabled = true
	node.light_cull_mask &= ~STATIC_LIGHTING_LAYER
	parent.add_child(node)


func _spawn_collision(parent: Node3D, model: CollisionFile.CollisionModel) -> void:
	var body := StaticBody3D.new()
	parent.add_child(body)

	for box in model.boxes:
		var aabb := AABB()
		aabb.position = Vector3(
			min(box.min.x, box.max.x),
			min(box.min.y, box.max.y),
			min(box.min.z, box.max.z),
		)
		aabb.end = Vector3(
			max(box.min.x, box.max.x),
			max(box.min.y, box.max.y),
			max(box.min.z, box.max.z),
		)
		if aabb.size.x <= 0 or aabb.size.y <= 0 or aabb.size.z <= 0:
			continue
		var shape := BoxShape3D.new()
		shape.size = aabb.size
		var colshape := CollisionShape3D.new()
		colshape.shape = shape
		colshape.position = aabb.get_center()
		body.add_child(colshape)

	if model.mesh_faces.size() > 0:
		var shape := ConcavePolygonShape3D.new()
		shape.set_faces(model.mesh_faces)
		var colshape := CollisionShape3D.new()
		colshape.shape = shape
		body.add_child(colshape)
