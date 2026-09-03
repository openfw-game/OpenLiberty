class_name ResourceFormatLoaderRWClump
extends ResourceFormatLoader

enum {
	## Disabled
	FILTER_NONE = 0,
	## Point sampled
	FILTER_NEAREST = 1,
	## Bilinear
	FILTER_LINEAR = 2,
	## Point sampled per pixel mip map
	FILTER_MIP_NEAREST = 3,
	## Bilinear per pixel mipmap
	FILTER_MIP_LINEAR = 4,
	## MipMap interp point sampled
	FILTER_LINEAR_MIP_NEAREST = 5,
	## Trilinear
	FILTER_LINEAR_MIP_LINEAR = 6,
}

enum {
	## Is triangle strip (if disabled it will be an triangle list)
	TRI_STRP = 0x00000001,
	## Vertex translation
	POSITIONS = 0x00000002,
	## Texture coordinates
	TEXTURED = 0x00000004,
	## Vertex colors
	PRELIT = 0x00000008,
	## Store normals
	NORMALS = 0x00000010,
	## Geometry is lit (dynamic and static)
	LIGHT = 0x00000020,
	## Modulate material color
	MODULATE_MATERIAL_COLOR = 0x00000040,
	## Texture coordinates 2
	TEXTURED2 = 0x00000080,
	## Native Geometry
	NATIVE = 0x01000000,
}

const RW_SHADER: Shader = preload("res://addons/atirutw.renderware/shaders/renderware.gdshader")


func _get_recognized_extensions() -> PackedStringArray:
	return PackedStringArray(["dff"])


func _handles_type(type: StringName) -> bool:
	return type == &"Resource"


func _load(path: String, original_path: String, use_sub_threads: bool, cache_mode: int) -> Variant:
	var chunk := RWChunk.open(path)
	if chunk == null:
		return ERR_FILE_NOT_FOUND

	var clump := _read_clump(chunk)
	if clump == null:
		return ERR_INVALID_DATA
	return clump


func _read_clump(rw_clump: RWChunk) -> RWClump:
	if !rw_clump.expect(RWChunk.CLUMP):
		return null
	var children := rw_clump.get_children()
	var struct := rw_clump.get_struct_stream()
	if struct == null:
		return null

	var clump := RWClump.new()
	var num_atomics := struct.get_32()
	if rw_clump.version > 0x33000:
		struct.get_32() # num_lights
		struct.get_32() # num_cameras

	if _read_frame_list(children[1], clump.frames) != OK:
		return null
	if _read_geometry_list(children[2], clump.geometries) != OK:
		return null
	for atomic: RWChunk in children.slice(3, 3 + num_atomics):
		if _read_atomic(atomic, clump) != OK:
			return null

	return clump


func _read_frame_list(frame_list: RWChunk, out_frames: Array[RWClump.Frame]) -> Error:
	if !frame_list.expect(RWChunk.FRAME_LIST):
		return ERR_INVALID_DATA
	var struct := frame_list.get_struct_stream()
	if struct == null:
		return ERR_INVALID_DATA

	for i in struct.get_32():
		var vecs: Array[Vector3] = []
		for j in 4:
			var x := struct.get_float()
			var y := struct.get_float()
			var z := struct.get_float()
			vecs.append(Vector3(x, y, z))
		var parent_index := struct.get_32()
		struct.get_32() # Unused flags

		var frame := RWClump.Frame.new()
		frame.parent_index = parent_index
		frame.transform = Transform3D(Basis(vecs[0], vecs[1], vecs[2]), vecs[3])
		out_frames.append(frame)

	return OK


func _read_geometry_list(glist: RWChunk, out_geometries: Array[ArrayMesh]) -> Error:
	if !glist.expect(RWChunk.GEOMETRY_LIST):
		return ERR_INVALID_DATA
	var struct := glist.get_struct_stream()
	if struct == null:
		return ERR_INVALID_DATA

	var geometries := glist.get_children().slice(1)
	for geometry: RWChunk in geometries:
		var mesh := _read_geometry(geometry)
		if mesh == null:
			return ERR_INVALID_DATA
		out_geometries.append(mesh)

	return OK


func _read_geometry(geometry: RWChunk) -> ArrayMesh:
	if !geometry.expect(RWChunk.GEOMETRY):
		return null
	var struct := geometry.get_struct_stream()
	if struct == null:
		return null

	var materials: Array[ShaderMaterial] = []
	if _read_material_list(geometry.get_children()[1], materials) != OK:
		return null

	var format := struct.get_32()
	var num_tris := struct.get_32()
	var num_verts := struct.get_32()
	var num_morphs := struct.get_32()
	# TODO: Expand triangle strips when TRI_STRP is set.
	if num_morphs == 0:
		push_error("Geometry has no morph targets")
		return null

	var ambient := struct.get_float() if geometry.version < 0x34000 else 0.0
	var specular := struct.get_float() if geometry.version < 0x34000 else 0.0
	var diffuse := struct.get_float() if geometry.version < 0x34000 else 0.0

	for mat in materials:
		if geometry.version <= 0x30400:
			mat.set_shader_parameter("ambient", ambient)
			mat.set_shader_parameter("specular", specular)
			mat.set_shader_parameter("diffuse", diffuse)
		mat.set_shader_parameter("modulate", format & MODULATE_MATERIAL_COLOR != 0)
		mat.set_shader_parameter("prelit", format & PRELIT != 0)
		# TODO: Models without the LIGHT flag still get dynamic lighting.
		mat.set_shader_parameter("lit", format & LIGHT != 0)

	if format & NATIVE != 0:
		push_error("Native geometries are not supported")
		return null

	var prelit_color := PackedColorArray()
	if format & PRELIT != 0:
		for i in num_verts:
			var color := Color()
			color.r8 = struct.get_u8()
			color.g8 = struct.get_u8()
			color.b8 = struct.get_u8()
			color.a8 = struct.get_u8()
			prelit_color.append(color)

	var uvs: Array[PackedVector2Array] = []
	for i in _get_num_uvs(format):
		var uv := PackedVector2Array()
		for j in num_verts:
			var x := struct.get_float()
			var y := struct.get_float()
			uv.append(Vector2(x, y))
		uvs.append(uv)

	# Triangles mapped by material ID
	var tris: Dictionary[int, PackedInt32Array] = { }
	for i in num_tris:
		var v1 := struct.get_u16()
		var v2 := struct.get_u16()
		var mat := struct.get_u16()
		var v3 := struct.get_u16()

		if mat >= materials.size():
			push_error("Geometry references invalid material index %d" % mat)
			return null

		if !tris.has(mat):
			tris[mat] = PackedInt32Array()
		tris[mat].append(v1)
		tris[mat].append(v2)
		tris[mat].append(v3)

	var morph_vertices: Array[PackedVector3Array] = []
	var morph_normals: Array[PackedVector3Array] = []
	for i in num_morphs:
		struct.get_float() # Sphere x
		struct.get_float() # Sphere y
		struct.get_float() # Sphere z
		struct.get_float() # Sphere radius
		var has_verts := struct.get_32() != 0
		var has_norms := struct.get_32() != 0

		if has_verts:
			var verts := PackedVector3Array()
			for j in num_verts:
				verts.append(Vector3(struct.get_float(), struct.get_float(), struct.get_float()))
			morph_vertices.append(verts)
		else:
			morph_vertices.append(PackedVector3Array())

		if has_norms:
			var norms := PackedVector3Array()
			for j in num_verts:
				norms.append(Vector3(struct.get_float(), struct.get_float(), struct.get_float()))
			morph_normals.append(norms)
		else:
			morph_normals.append(PackedVector3Array())

	var mesh := ArrayMesh.new()
	for i in range(1, num_morphs):
		mesh.add_blend_shape("morph_%d" % i)

	var surface_index := 0
	for mat_id in tris:
		var arrays := []
		arrays.resize(Mesh.ARRAY_MAX)
		arrays[Mesh.ARRAY_VERTEX] = morph_vertices[0]
		if morph_normals[0].size() > 0:
			arrays[Mesh.ARRAY_NORMAL] = morph_normals[0]
		if prelit_color.size() > 0:
			arrays[Mesh.ARRAY_COLOR] = prelit_color
		for uv_idx in uvs.size():
			arrays[Mesh.ARRAY_TEX_UV + uv_idx] = uvs[uv_idx]
		arrays[Mesh.ARRAY_INDEX] = tris[mat_id]

		var blend_shapes: Array = []
		for bi in range(1, num_morphs):
			var bs := []
			bs.resize(Mesh.ARRAY_MAX)
			if morph_vertices[bi].size() > 0:
				bs[Mesh.ARRAY_VERTEX] = morph_vertices[bi]
			if morph_normals[bi].size() > 0:
				bs[Mesh.ARRAY_NORMAL] = morph_normals[bi]
			blend_shapes.append(bs)

		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays, blend_shapes)
		mesh.surface_set_material(surface_index, materials[mat_id])
		surface_index += 1

	return mesh


func _get_num_uvs(format: int) -> int:
	if (format & 0x00ff0000) >> 16 != 0:
		return (format & 0x00ff0000) >> 16
	elif format & TEXTURED2 != 0:
		return 2
	elif format & TEXTURED != 0:
		return 1
	else:
		return 0


func _read_material_list(mlist: RWChunk, out_materials: Array[ShaderMaterial]) -> Error:
	if !mlist.expect(RWChunk.MATERIAL_LIST):
		return ERR_INVALID_DATA
	var struct := mlist.get_struct_stream()
	if struct == null:
		return ERR_INVALID_DATA

	var indices: Array[int] = []
	for i in struct.get_32():
		indices.append(struct.get_32())

	var children := mlist.get_children()
	var material_child := 1
	for i in indices:
		if i == -1:
			var material := _read_material(children[material_child])
			if material == null:
				return ERR_INVALID_DATA
			out_materials.append(material)
			material_child += 1
		else:
			if i < 0 or i >= out_materials.size():
				push_error("Material list references invalid material index %d" % i)
				return ERR_INVALID_DATA
			out_materials.append(out_materials[i])

	return OK


func _read_material(rw_material: RWChunk) -> ShaderMaterial:
	if !rw_material.expect(RWChunk.MATERIAL):
		return null
	var struct := rw_material.get_struct_stream()
	if struct == null:
		return null

	struct.get_32() # Unused flags
	var color := Color.from_rgba8(
		struct.get_u8(),
		struct.get_u8(),
		struct.get_u8(),
		struct.get_u8(),
	)
	struct.get_32() # Unused whatever
	var textured := struct.get_32() & 1 != 0

	var ambient := struct.get_float() if rw_material.version > 0x30400 else 0.0
	var specular := struct.get_float() if rw_material.version > 0x30400 else 0.0
	var diffuse := struct.get_float() if rw_material.version > 0x30400 else 0.0

	var material := ShaderMaterial.new()
	material.shader = RW_SHADER
	material.set_shader_parameter("color", color)
	if rw_material.version > 0x30400:
		material.set_shader_parameter("ambient", ambient)
		material.set_shader_parameter("specular", specular)
		material.set_shader_parameter("diffuse", diffuse)

	if !textured:
		return material

	# Okay, I know this breaks convention by reading a separate chunk here,
	# but I don't really know how else to carry filtering information.
	# Texture
	var tex: RWChunk = rw_material.get_children()[1]
	if !tex.expect(RWChunk.TEXTURE):
		return null

	var tex_struct := tex.get_struct_stream()
	if tex_struct == null:
		return null
	tex_struct.get_u8() # Filter mode; unsupported
	tex_struct.get_u8() # Separate U/V addressing modes; unsupported
	tex_struct.get_u16() # Mipmap flag; unsupported

	var tex_children: Array[RWChunk] = tex.get_children()
	var texname_stream := tex_children[1].get_stream()
	if texname_stream == null:
		return null
	var texname := texname_stream.get_string(texname_stream.get_available_bytes())
	var maskname_stream := tex_children[2].get_stream()
	if maskname_stream == null:
		return null
	var maskname := maskname_stream.get_string(maskname_stream.get_available_bytes())

	material.set_meta("texture_name", texname)
	material.set_meta("mask_name", maskname)

	return material


func _read_atomic(atomic: RWChunk, clump: RWClump) -> Error:
	if !atomic.expect(RWChunk.ATOMIC):
		return FAILED
	var struct := atomic.get_struct_stream()
	if struct == null:
		return FAILED

	var data := RWClump.Atomic.new()
	data.frame_index = struct.get_32()
	data.geometry_index = struct.get_32()
	clump.atomics.append(data)
	return OK
