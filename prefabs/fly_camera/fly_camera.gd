extends Node3D

@onready var x_coordinate := $camera_position_x as Label
@onready var y_coordinate := $camera_position_y as Label
@onready var z_coordinate := $camera_position_z as Label

var sensitivity := 2.0
@export var move_speed := 240.0

const MAX_PITCH := 89.0

var _yaw_deg := 0.0
var _pitch_deg := 0.0


func _process(delta: float) -> void:
	if x_coordinate != null:
		x_coordinate.text = str(global_position.x)
	if y_coordinate != null:
		y_coordinate.text = str(global_position.y)
	if z_coordinate != null:
		z_coordinate.text = str(global_position.z)

	# Movement is relative to the camera's orientation: flycam_forward/backward
	# move along the camera's -Z/+Z, left/right along its X axis, up/down along
	# its Y axis.
	var input := Input.get_vector(
		"flycam_left",
		"flycam_right",
		"flycam_forward",
		"flycam_backward",
	)
	var dir := Vector3(input.x, 0, input.y)
	if Input.is_action_pressed("flycam_up"):
		dir.y += 1.0
	if Input.is_action_pressed("flycam_down"):
		dir.y -= 1.0
	if dir.length() > 0.0:
		var basis := global_transform.basis
		global_position += (basis * dir.normalized()) * move_speed * delta


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event):
	if event is InputEventMouseMotion:
		# Keep yaw and pitch separate. Clamping the pitch prevents the camera
		# from flipping upside-down, which inverts the vertical mouse axis.
		_yaw_deg -= event.relative.x * sensitivity
		_pitch_deg = clampf(_pitch_deg - event.relative.y * sensitivity, -MAX_PITCH, MAX_PITCH)
		transform.basis = Basis(Vector3.UP, deg_to_rad(_yaw_deg)) * Basis(
			Vector3.RIGHT,
			deg_to_rad(_pitch_deg),
		)
