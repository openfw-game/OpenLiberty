extends Node

var world: Node3D

@onready var sun = $sun
@onready var moon = $moon
@onready var sky = $WorldEnvironment

func _ready() -> void:
	var map := MapData.open(NoCaseFS.resolve(GameManager.gta_path.path_join("data/gta3.dat")))
	if map == null:
		return
	world = map.instantiate()
	add_child(world)

	sky.environment = load("res://scenes/world/day.tres")
	moon.visible = not moon.visible

func _unhandled_input(event: InputEvent) -> void:
	pass

func _input(event):
	if Input.is_action_just_pressed("full_screen"):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	#else:
		#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	if Input.is_action_just_pressed("night_toggle"):
		sky.environment = load("res://scenes/world/night.tres")
		sun.visible = not sun.visible
		moon.visible = not moon.visible
		#if sun.visible = true
			#sky.environment = load("res://scenes/world/day.tres")
