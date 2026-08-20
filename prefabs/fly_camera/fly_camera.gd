extends Node3D


@onready var x_coordinate = $camera_position_x
@onready var y_coordinate = $camera_position_y
@onready var z_coordinate = $camera_position_z

var sensitivity = 2.0

func _process(delta):
	x_coordinate.text = str(self.position.x)
	y_coordinate.text = str(self.position.y)
	z_coordinate.text = str(self.position.z)
	if Input.is_action_pressed("flycam_up"):
		position.y = position.y + 1
	if Input.is_action_pressed("flycam_down"):
		position.y = position.y - 1
	if Input.is_action_pressed("flycam_left"):
		position.x = position.x + 1
	if Input.is_action_pressed("flycam_right"):
		position.x = position.x - 1
	if Input.is_action_pressed("flycam_forward"):
		position.x = position.x + 1
		position.y = position.y + 1
		position.z = position.z + 1
	if Input.is_action_pressed("flycam_backward"):
		position.x = position.x - 1
		position.y = position.y - 1
		position.z = position.z - 1

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sensitivity))
		rotate_x(deg_to_rad(event.relative.y * sensitivity))
		rotation.z = 0
