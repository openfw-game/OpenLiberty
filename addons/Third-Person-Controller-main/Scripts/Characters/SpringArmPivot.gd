extends Node3D

@export_group("FOV")
@export var change_fov_on_run : bool
@export var normal_fov : float = 75.0
@export var run_fov : float = 90.0

const CAMERA_BLEND : float = 0.05

@onready var spring_arm : SpringArm3D = $SpringArm3D
@onready var camera : Camera3D = $SpringArm3D/OLCamera

var is_cursor_visible:bool = false

func _ready():
	DebugManager.debug_mode_changed.connect(_on_debug_mode_changed)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * 0.005)
		spring_arm.rotate_x(-event.relative.y * 0.005)
		spring_arm.rotation.x = clamp(spring_arm.rotation.x, -PI/4, PI/4)

func _physics_process(_delta):
	if change_fov_on_run:
		if owner.is_on_floor():
			if Input.is_action_pressed("run"):
				camera.fov = lerp(camera.fov, run_fov, CAMERA_BLEND)
			else:
				camera.fov = lerp(camera.fov, normal_fov, CAMERA_BLEND)
		else:
			camera.fov = lerp(camera.fov, normal_fov, CAMERA_BLEND)

func _on_debug_mode_changed(_mode:DebugManager.DebugMode) -> void:
	match _mode:
		DebugManager.DebugMode.ENABLED:
			set_process_input(false)
			set_process(false)
			set_physics_process(false)
		DebugManager.DebugMode.DISABLED:
			set_process_input(true)
			set_process(true)
			set_physics_process(true)
