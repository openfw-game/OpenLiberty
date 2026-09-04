extends Node3D

@export var speed: float = 100
@export var sensitivity: float = 1


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta: float) -> void:
	var movement := Vector3.ZERO

	if Input.is_action_pressed("flycam_forward"):
		movement -= global_basis.z
	if Input.is_action_pressed("flycam_backward"):
		movement += global_basis.z
	if Input.is_action_pressed("flycam_left"):
		movement -= global_basis.x
	if Input.is_action_pressed("flycam_right"):
		movement += global_basis.x
	if Input.is_action_pressed("flycam_up"):
		movement += global_basis.y
	if Input.is_action_pressed("flycam_down"):
		movement -= global_basis.y

	if movement == Vector3.ZERO:
		return

	position += movement.normalized() * delta * (
		speed if !Input.is_key_pressed(KEY_SHIFT) else speed * 2
	)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation.y += deg_to_rad(-event.relative.x * sensitivity)
		rotation.x = clampf(rotation.x + deg_to_rad(-event.relative.y * sensitivity), -PI / 2, PI / 2)
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			speed *= 1.25
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			speed /= 1.25
