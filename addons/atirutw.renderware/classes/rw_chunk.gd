class_name RWChunk
extends RefCounted

enum {
	## Struct
	STRUCT = 0x00000001,
	## String
	STRING = 0x00000002,
	## Extension
	EXTENSION = 0x00000003,
	## Camera
	CAMERA = 0x00000005,
	## Texture
	TEXTURE = 0x00000006,
	## Material
	MATERIAL = 0x00000007,
	## Material List
	MATERIAL_LIST = 0x00000008,
	## World Section (Atomic Section)
	WORLD_SECTION = 0x00000009,
	## Plane Section
	PLANE_SECTION = 0x0000000A,
	## World
	WORLD = 0x0000000B,
	## Spline
	SPLINE = 0x0000000C,
	## Matrix
	MATRIX = 0x0000000D,
	## Frame List
	FRAME_LIST = 0x0000000E,
	## Geometry
	GEOMETRY = 0x0000000F,
	## Clump
	CLUMP = 0x00000010,
	## Light
	LIGHT = 0x00000012,
	## Unicode String
	UNICODE_STRING = 0x00000013,
	## Atomic
	ATOMIC = 0x00000014,
	## Raster
	RASTER = 0x00000015,
	## Texture Dictionary
	TEXTURE_DICTIONARY = 0x00000016,
	## Animation Database
	ANIMATION_DATABASE = 0x00000017,
	## Image
	IMAGE = 0x00000018,
	## Skin Animation
	SKIN_ANIMATION = 0x00000019,
	## Geometry List
	GEOMETRY_LIST = 0x0000001A,
	## Anim Animation
	ANIM_ANIMATION = 0x0000001B,
	## Team
	TEAM = 0x0000001C,
	## Crowd
	CROWD = 0x0000001D,
	## Delta Morph Animation
	DELTA_MORPH_ANIMATION = 0x0000001E,
	## Right To Render
	RIGHT_TO_RENDER = 0x0000001F,
	## MultiTexture Effect Native
	MULTITEXTURE_EFFECT_NATIVE = 0x00000020,
	## MultiTexture Effect Dictionary
	MULTITEXTURE_EFFECT_DICTIONARY = 0x00000021,
	## Team Dictionary
	TEAM_DICTIONARY = 0x00000022,
	## Platform Independent Texture Dictionary
	PLATFORM_INDEPENDENT_TEXTURE_DICTIONARY = 0x00000023,
	## Table of Contents
	TABLE_OF_CONTENTS = 0x00000024,
	## Particle Standard Global Data
	PARTICLE_STANDARD_GLOBAL_DATA = 0x00000025,
	## AltPipe
	ALTPIPE = 0x00000026,
	## Platform Independent Peds
	PLATFORM_INDEPENDENT_PEDS = 0x00000027,
	## Patch Mesh
	PATCH_MESH = 0x00000028,
	## Chunk Group Start
	CHUNK_GROUP_START = 0x00000029,
	## Chunk Group End
	CHUNK_GROUP_END = 0x0000002A,
	## UV Animation Dictionary
	UV_ANIMATION_DICTIONARY = 0x0000002B,
	## Coll Tree
	COLL_TREE = 0x0000002C,
	## Metrics PLG
	METRICS_PLG = 0x00000101,
	## Spline PLG
	SPLINE_PLG = 0x00000102,
	## Stereo PLG
	STEREO_PLG = 0x00000103,
	## VRML PLG
	VRML_PLG = 0x00000104,
	## Morph PLG
	MORPH_PLG = 0x00000105,
	## PVS PLG
	PVS_PLG = 0x00000106,
	## Memory Leak PLG
	MEMORY_LEAK_PLG = 0x00000107,
	## Animation PLG
	ANIMATION_PLG = 0x00000108,
	## Gloss PLG
	GLOSS_PLG = 0x00000109,
	## Logo PLG
	LOGO_PLG = 0x0000010A,
	## Memory Info PLG
	MEMORY_INFO_PLG = 0x0000010B,
	## Random PLG
	RANDOM_PLG = 0x0000010C,
	## PNG Image PLG
	PNG_IMAGE_PLG = 0x0000010D,
	## Bone PLG
	BONE_PLG = 0x0000010E,
	## VRML Anim PLG
	VRML_ANIM_PLG = 0x0000010F,
	## Sky Mipmap Val
	SKY_MIPMAP_VAL = 0x00000110,
	## MRM PLG
	MRM_PLG = 0x00000111,
	## LOD Atomic PLG
	LOD_ATOMIC_PLG = 0x00000112,
	## ME PLG
	ME_PLG = 0x00000113,
	## Lightmap PLG
	LIGHTMAP_PLG = 0x00000114,
	## Refine PLG
	REFINE_PLG = 0x00000115,
	## Skin PLG
	SKIN_PLG = 0x00000116,
	## Label PLG
	LABEL_PLG = 0x00000117,
	## Particles PLG
	PARTICLES_PLG = 0x00000118,
	## GeomTX PLG
	GEOMTX_PLG = 0x00000119,
	## Synth Core PLG
	SYNTH_CORE_PLG = 0x0000011A,
	## STQPP PLG
	STQPP_PLG = 0x0000011B,
	## Part PP PLG
	PART_PP_PLG = 0x0000011C,
	## Collision PLG
	COLLISION_PLG = 0x0000011D,
	## HAnim PLG
	HANIM_PLG = 0x0000011E,
	## User Data PLG
	USER_DATA_PLG = 0x0000011F,
	## Material Effects PLG
	MATERIAL_EFFECTS_PLG = 0x00000120,
	## Particle System PLG
	PARTICLE_SYSTEM_PLG = 0x00000121,
	## Delta Morph PLG
	DELTA_MORPH_PLG = 0x00000122,
	## Patch PLG
	PATCH_PLG = 0x00000123,
	## Team PLG
	TEAM_PLG = 0x00000124,
	## Crowd PP PLG
	CROWD_PP_PLG = 0x00000125,
	## Mip Split PLG
	MIP_SPLIT_PLG = 0x00000126,
	## Anisotropy PLG
	ANISOTROPY_PLG = 0x00000127,
	## GCN Material PLG
	GCN_MATERIAL_PLG = 0x00000129,
	## Geometric PVS PLG
	GEOMETRIC_PVS_PLG = 0x0000012A,
	## XBOX Material PLG
	XBOX_MATERIAL_PLG = 0x0000012B,
	## Multi Texture PLG
	MULTI_TEXTURE_PLG = 0x0000012C,
	## Chain PLG
	CHAIN_PLG = 0x0000012D,
	## Toon PLG
	TOON_PLG = 0x0000012E,
	## PTank PLG
	PTANK_PLG = 0x0000012F,
	## Particle Standard PLG
	PARTICLE_STANDARD_PLG = 0x00000130,
	## PDS PLG
	PDS_PLG = 0x00000131,
	## PrtAdv PLG
	PRTADV_PLG = 0x00000132,
	## Normal Map PLG
	NORMAL_MAP_PLG = 0x00000133,
	## ADC PLG
	ADC_PLG = 0x00000134,
	## UV Animation PLG
	UV_ANIMATION_PLG = 0x00000135,
	## Character Set PLG
	CHARACTER_SET_PLG = 0x00000180,
	## NOHS World PLG
	NOHS_WORLD_PLG = 0x00000181,
	## Import Util PLG
	IMPORT_UTIL_PLG = 0x00000182,
	## Slerp PLG
	SLERP_PLG = 0x00000183,
	## Optim PLG
	OPTIM_PLG = 0x00000184,
	## TL World PLG
	TL_WORLD_PLG = 0x00000185,
	## Database PLG
	DATABASE_PLG = 0x00000186,
	## Raytrace PLG
	RAYTRACE_PLG = 0x00000187,
	## Ray PLG
	RAY_PLG = 0x00000188,
	## Library PLG
	LIBRARY_PLG = 0x00000189,
	## 2D PLG
	TWOD_PLG = 0x00000190,
	## Tile Render PLG
	TILE_RENDER_PLG = 0x00000191,
	## JPEG Image PLG
	JPEG_IMAGE_PLG = 0x00000192,
	## TGA Image PLG
	TGA_IMAGE_PLG = 0x00000193,
	## GIF Image PLG
	GIF_IMAGE_PLG = 0x00000194,
	## Quat PLG
	QUAT_PLG = 0x00000195,
	## Spline PVS PLG
	SPLINE_PVS_PLG = 0x00000196,
	## Mipmap PLG
	MIPMAP_PLG = 0x00000197,
	## MipmapK PLG
	MIPMAPK_PLG = 0x00000198,
	## 2D Font
	TWOD_FONT = 0x00000199,
	## Intersection PLG
	INTERSECTION_PLG = 0x0000019A,
	## TIFF Image PLG
	TIFF_IMAGE_PLG = 0x0000019B,
	## Pick PLG
	PICK_PLG = 0x0000019C,
	## BMP Image PLG
	BMP_IMAGE_PLG = 0x0000019D,
	## RAS Image PLG
	RAS_IMAGE_PLG = 0x0000019E,
	## Skin FX PLG
	SKIN_FX_PLG = 0x0000019F,
	## VCAT PLG
	VCAT_PLG = 0x000001A0,
	## 2D Path
	TWOD_PATH = 0x000001A1,
	## 2D Brush
	TWOD_BRUSH = 0x000001A2,
	## 2D Object
	TWOD_OBJECT = 0x000001A3,
	## 2D Shape
	TWOD_SHAPE = 0x000001A4,
	## 2D Scene
	TWOD_SCENE = 0x000001A5,
	## 2D Pick Region
	TWOD_PICK_REGION = 0x000001A6,
	## 2D Object String
	TWOD_OBJECT_STRING = 0x000001A7,
	## 2D Animation PLG
	TWOD_ANIMATION_PLG = 0x000001A8,
	## 2D Animation
	TWOD_ANIMATION = 0x000001A9,
	## 2D Keyframe
	TWOD_KEYFRAME = 0x000001B0,
	## 2D Maestro
	TWOD_MAESTRO = 0x000001B1,
	## Barycentric
	BARYCENTRIC = 0x000001B2,
	## Platform Independent Texture Dictionary TK
	PLATFORM_INDEPENDENT_TEXTURE_DICTIONARY_TK = 0x000001B3,
	## TOC TK
	TOC_TK = 0x000001B4,
	## TPL TK
	TPL_TK = 0x000001B5,
	## AltPipe TK
	ALTPIPE_TK = 0x000001B6,
	## Animation TK
	ANIMATION_TK = 0x000001B7,
	## Skin Split Tookit
	SKIN_SPLIT_TOOKIT = 0x000001B8,
	## Compressed Key TK
	COMPRESSED_KEY_TK = 0x000001B9,
	## Geometry Conditioning PLG
	GEOMETRY_CONDITIONING_PLG = 0x000001BA,
	## Wing PLG
	WING_PLG = 0x000001BB,
	## Generic Pipeline TK
	GENERIC_PIPELINE_TK = 0x000001BC,
	## Lightmap Conversion TK
	LIGHTMAP_CONVERSION_TK = 0x000001BD,
	## Filesystem PLG
	FILESYSTEM_PLG = 0x000001BE,
	## Dictionary TK
	DICTIONARY_TK = 0x000001BF,
	## UV Animation Linear
	UV_ANIMATION_LINEAR = 0x000001C0,
	## UV Animation Parameter
	UV_ANIMATION_PARAMETER = 0x000001C1,
	## Bin Mesh PLG
	BIN_MESH_PLG = 0x0000050E,
	## Native Data PLG
	NATIVE_DATA_PLG = 0x00000510,
	## EARS Material Data
	EARS_MATERIAL_DATA = 0x0000EA13,
	## EARS
	EARS_0000EA15 = 0x0000EA15,
	## EARS Mesh Plugin
	EARS_MESH_PLUGIN = 0x0000EA16,
	## EARS Instanced Plugin
	EARS_INSTANCED_PLUGIN = 0x0000EA20,
	## EARS Zone Plugin
	EARS_ZONE_PLUGIN = 0x0000EA28,
	## EARS Lt Map 2
	EARS_LT_MAP_2 = 0x0000EA2D,
	## EARS Rp Partial Instance
	EARS_RP_PARTIAL_INSTANCE = 0x0000EA2E,
	## EARS Texture Plugin
	EARS_TEXTURE_PLUGIN = 0x0000EA2F,
	## EARS Mesh
	EARS_MESH = 0x0000EA33,
	## EARS Atomic Plugin
	EARS_ATOMIC_PLUGIN = 0x0000EA40,
	## EARS Display List
	EARS_DISPLAY_LIST = 0x0000EA44,
	## EARS Rp Shader
	EARS_RP_SHADER = 0x0000EA45,
	## EARS Rp Alchemy
	EARS_RP_ALCHEMY = 0x0000EA80,
	## EARS Morph Target Data
	EARS_MORPH_TARGET_DATA = 0x0000EA92,
	## ZModeler Lock
	ZMODELER_LOCK = 0x0000F21E,
	## THQ Atomic
	THQ_ATOMIC = 0x00CAFE40,
	## THQ Material
	THQ_MATERIAL = 0x00CAFE45,
	## Atomic Visibility Distance
	ATOMIC_VISIBILITY_DISTANCE = 0x0253F200,
	## Clump Visibility Distance
	CLUMP_VISIBILITY_DISTANCE = 0x0253F201,
	## Frame Visibility Distance
	FRAME_VISIBILITY_DISTANCE = 0x0253F202,
	## Pipeline Set
	PIPELINE_SET = 0x0253F2F3,
	## TexDictionary Link
	TEXDICTIONARY_LINK = 0x0253F2F5,
	## Specular Material
	SPECULAR_MATERIAL = 0x0253F2F6,
	## 2d Effect
	TWOD_EFFECT = 0x0253F2F8,
	## Extra Vert Colour
	EXTRA_VERT_COLOUR = 0x0253F2F9,
	## Collision Model
	COLLISION_MODEL = 0x0253F2FA,
	## GTA HAnim
	GTA_HANIM = 0x0253F2FB,
	## Reflection Material
	REFLECTION_MATERIAL = 0x0253F2FC,
	## Breakable
	BREAKABLE = 0x0253F2FD,
	## Frame
	FRAME = 0x0253F2FE,
}

var type: int
var version: int
var build: int

var _data: PackedByteArray


static func open(path: String) -> RWChunk:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Could not open %s: %s" % [path, error_string(FileAccess.get_open_error())])
		return null

	if file.get_length() - file.get_position() < 12:
		push_error("File too short: %s" % path)
		return null

	var type := file.get_32()
	var size := file.get_32()
	var stamp := file.get_32()

	if file.get_length() - file.get_position() < size:
		push_error("Chunk size (%d) exceeds file size: %s" % [size, path])
		return null

	var chunk := RWChunk.new()
	chunk.type = type
	chunk.version = _unpack_version(stamp)
	chunk.build = _unpack_build(stamp)
	chunk._data = file.get_buffer(size)

	return chunk


static func _unpack_version(stamp: int) -> int:
	if stamp & 0xffff0000 != 0:
		return (stamp >> 14 & 0x3ff00) + 0x30000 | (stamp >> 16 & 0x3f)
	return stamp << 8


static func _unpack_build(stamp: int) -> int:
	if stamp & 0xffff0000 != 0:
		return stamp & 0xffff
	return 0


## Gets the content of the chunk as a StreamPeerBuffer.
func get_stream() -> StreamPeerBuffer:
	var stream := StreamPeerBuffer.new()
	stream.data_array = _data
	return stream


## Gets the children of the chunk as an array of RWChunk.
func get_children() -> Array[RWChunk]:
	var stream := get_stream()
	var children: Array[RWChunk] = []

	while stream.get_available_bytes() >= 12:
		var type := stream.get_32()
		var size := stream.get_32()
		var stamp := stream.get_32()

		if stream.get_available_bytes() < size:
			push_error(
				"Child chunk size (%d) exceeds remaining bytes: %d"
				% [size, stream.get_available_bytes()]
			)
			return children

		var child := RWChunk.new()
		child.type = type
		child.version = _unpack_version(stamp)
		child.build = _unpack_build(stamp)
		child._data = _data.slice(stream.get_position(), stream.get_position() + size)
		children.append(child)
		stream.seek(stream.get_position() + size)

	return children


func get_struct_stream() -> StreamPeerBuffer:
	var children := get_children()
	if children.size() == 0:
		push_error("No children found")
		return null
	if !children[0].expect(RWChunk.STRUCT):
		return null
	return children[0].get_stream()


func expect(type: int) -> bool:
	if type != self.type:
		push_error("Expected chunk type %d, got %d" % [type, self.type])
		return false
	return true
