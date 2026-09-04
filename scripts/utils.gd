class_name Utils
extends RefCounted

const GTA_TO_GODOT := Transform3D(
	Basis(Vector3(1, 0, 0), Vector3(0, 0, -1), Vector3(0, 1, 0)),
	Vector3.ZERO,
)

static func gta_to_godot(xform: Transform3D) -> Transform3D:
	return GTA_TO_GODOT * xform
