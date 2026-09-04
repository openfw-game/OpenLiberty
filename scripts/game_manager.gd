extends Node

var gta_path: String


func _ready() -> void:
	if OS.has_feature("editor"):
		gta_path = ProjectSettings.globalize_path("res://gta")
	else:
		gta_path = OS.get_executable_path().get_base_dir()
	print("GTA path: %s" % gta_path)
	NoCaseFS.index(gta_path)
	ModelFS.clear()
	ModelFS.add_directory(gta_path.path_join("models"))
	ModelFS.add_cd_image(gta_path.path_join("models/gta3.img"))


func _exit_tree() -> void:
	ModelFS.clear()
