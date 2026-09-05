class_name RWClump
extends Resource

var frames: Array[Frame] = []
var geometries: Array[ArrayMesh] = []
var atomics: Array[Atomic] = []


class Frame:
	var transform: Transform3D
	var parent_index: int


class Atomic:
	enum {
		## This atomic is used during collision detection.
		COLLISION = 0x01,
		## This atomic is used during rendering.
		RENDER = 0x04,
	}

	var frame_index: int
	var geometry_index: int
	var flags: int
