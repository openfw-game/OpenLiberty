class_name RWGeometry
extends RWChunk

enum {
	rpGEOMETRYTRISTRIP = 0x00000001,
	rpGEOMETRYPOSITIONS = 0x00000002,
	rpGEOMETRYTEXTURED = 0x00000004,
	rpGEOMETRYPRELIT = 0x00000008,
	rpGEOMETRYNORMALS = 0x00000010,
	rpGEOMETRYLIGHT = 0x00000020,
	rpGEOMETRYMODULATEMATERIALCOLOR = 0x00000040,
	rpGEOMETRYTEXTURED2 = 0x00000080,
	rpGEOMETRYNATIVE = 0x01000000,
}

var format: int
var tri_count: int
var vert_count: int
var morph_target_count: int

# These are only used if version < 0x34000
var ambient: float
var specular: float
var diffuse: float
var uv_count: int
var uvs: Array[PackedVector2Array]
var tris: Array[Triangle]
var morph_targets: Array[MorphTarget]
var material_list: RWMaterialList

var mesh: ArrayMesh:
	get:
		if morph_targets[0].has_vertices == false:
			return ArrayMesh.new()
		var morph_t := morph_targets[0]
		var st := SurfaceTool.new()
		var surfaces: Dictionary[int, Array] = {}
		# Split tris by their material ID
		for tri in tris:
			var mat_id := tri.material_id
			if not mat_id in surfaces:
				surfaces[mat_id] = []
			surfaces[mat_id].append(tri)
		for surf_id in surfaces:
			st.begin(Mesh.PRIMITIVE_TRIANGLES)
			var surface = surfaces[surf_id] as Array[Triangle]
			for tri in surface:
				for i in [3,2,1]:
					if morph_t.has_normals:
						st.set_normal(morph_t.normals[tri["vertex_%d" % i]])
					if uvs.size() > 0:
						st.set_uv(uvs[0][tri["vertex_%d" % i]])
					st.add_vertex(morph_t.vertices[tri["vertex_%d" % i]])
				var rwmaterial := material_list.materials[tri.material_id]
				var material := rwmaterial.material
				if rwmaterial.is_textured:
					material.set_meta("texture_name", rwmaterial.texture.texture_name)
				st.set_material(material)
			if format & rpGEOMETRYTRISTRIP == 0 and morph_t.has_normals == false:
				st.generate_normals()
			if mesh == null:
				mesh = st.commit()
			else:
				st.commit(mesh)
		return mesh

func _init(file: FileAccess):
	super(file)
	assert(type == ChunkType.GEOMETRY)
	RWChunk.new(file)
	format = file.get_32()
	tri_count = file.get_32()
	vert_count = file.get_32()
	morph_target_count = file.get_32()
	if version < 0x34000:
		ambient = file.get_float()
		specular = file.get_float()
		diffuse = file.get_float()
	if format & rpGEOMETRYNATIVE == 0:
		if format & rpGEOMETRYPRELIT:
			file.seek(file.get_position() + (vert_count * 4)) # Skip
		uv_count = (format & 0x00ff0000) >> 16
		if uv_count == 0:
			if format & rpGEOMETRYTEXTURED2:
				uv_count = 2
			elif format & rpGEOMETRYTEXTURED:
				uv_count = 1
		for i in uv_count:
			var coords := PackedVector2Array()
			for j in vert_count:
				var u := file.get_float()
				var v := file.get_float()
				coords.append(Vector2(u, v))
			uvs.append(coords)
		for i in tri_count:
			var tri := Triangle.new()
			tri.vertex_2 = file.get_16()
			tri.vertex_1 = file.get_16()
			tri.material_id = file.get_16()
			tri.vertex_3 = file.get_16()
			tris.append(tri)
	for i in morph_target_count:
		var morph_t := MorphTarget.new()
		morph_t.bounding_sphere = Sphere.new()
		morph_t.bounding_sphere.x = file.get_float()
		morph_t.bounding_sphere.y = file.get_float()
		morph_t.bounding_sphere.z = file.get_float()
		morph_t.bounding_sphere.radius = file.get_float()
		morph_t.has_vertices = file.get_32() != 0
		morph_t.has_normals = file.get_32() != 0
		if morph_t.has_vertices:
			for j in vert_count:
				# Convert GTA to Godot coordinate system
				var x := file.get_float()
				var y := file.get_float()
				var z := file.get_float()
				morph_t.vertices.append(Vector3(x, y, z))
		if morph_t.has_normals:
			for j in vert_count:
				var normal := Vector3()
				normal.x = file.get_float()
				normal.z = file.get_float()
				normal.y = file.get_float()
				morph_t.normals.append(normal)
		morph_targets.append(morph_t)
	material_list = RWMaterialList.new(file)
	skip(file)

class Triangle:
	var vertex_2: int
	var vertex_1: int
	var material_id: int
	var vertex_3: int

class MorphTarget:
	var bounding_sphere: Sphere
	var has_vertices: bool
	var has_normals: bool
	var vertices: Array[Vector3]
	var normals: Array[Vector3]

class Sphere:
	var x: float
	var y: float
	var z: float
	var radius: float
