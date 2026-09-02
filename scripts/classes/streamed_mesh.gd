class_name StreamedMesh
extends MeshInstance3D

var _idef: ItemDef
var _thread := Thread.new()
var _mesh_buf: Mesh
# I realized this is a very wrong way to load models off the main thread, but
# removing the mutex spawns way too many threads, and using ResourceLoader
# will be impossible until I refactor the RenderWare loading system.
# TODO: Remove this once RW layer is fully integrated into ResourceLoader.
static var mutex := Mutex.new()

func _init(idef: ItemDef):
	_idef = idef

func _exit_tree():
	if _thread.is_alive():
		_thread.wait_to_finish()

func _process(delta: float) -> void:
	if _thread.is_started() == false:
		if get_viewport().get_camera_3d() != null:
			var dist := get_viewport().get_camera_3d().global_position.distance_to(global_position)
			if dist < visibility_range_end and mesh == null:
				_thread.start(_load_mesh)
				while _thread.is_alive():
					await get_tree().process_frame
				_thread.wait_to_finish()
				mesh = _mesh_buf
			elif dist > visibility_range_end and mesh != null:
				mesh = null

func _load_mesh() -> void:
	mutex.lock()
	if _idef.flags & 0x40:
		mutex.unlock()
		return
	var access := ModelFS.open(_idef.model_name + ".dff", FileAccess.READ)
	if access == null:
		mutex.unlock()
		return
	var glist := RWClump.new(access).geometry_list
	for geometry in glist.geometries:
		_mesh_buf = geometry.mesh
		for surf_id in _mesh_buf.get_surface_count():
			var material := _mesh_buf.surface_get_material(surf_id) as StandardMaterial3D
			material.cull_mode = BaseMaterial3D.CULL_DISABLED
			if _idef.flags & 0x08:
				material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
				material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			if material.has_meta("texture_name"):
				var txd_access := ModelFS.open(_idef.txd_name + ".txd", FileAccess.READ)
				if txd_access == null:
					continue
				var txd := RWTextureDict.new(txd_access)
				var texture_name = material.get_meta("texture_name")
				for raster in txd.textures:
					if texture_name.matchn(raster.name):
						material.albedo_texture = ImageTexture.create_from_image(raster.image)
						if raster.has_alpha:
							material.transparency = (
								BaseMaterial3D.TRANSPARENCY_ALPHA_HASH if _idef.flags & 0x04 and not _idef.flags & 0x08
								else BaseMaterial3D.TRANSPARENCY_ALPHA )
						break
			_mesh_buf.surface_set_material(surf_id, material)
	mutex.unlock()
