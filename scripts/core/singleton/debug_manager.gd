extends Node

enum DebugMode {
	ENABLED,
	DISABLED
}

var current_mode:DebugMode = DebugMode.ENABLED

#region GODOT FUNCTION
func _process(delta: float) -> void:
	pass
#endregion

#region CALLS
func set_debug_mode(_mode:DebugMode) -> void:
	pass
#endregion
