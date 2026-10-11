extends CharacterBody3D
class_name Player

const LERP_VALUE : float = 0.15

var snap_vector : Vector3 = Vector3.DOWN
var speed : float

@export_group("Movement variables")
@export var walk_speed : float = 2.0
@export var run_speed : float = 5.0
@export var jump_strength : float = 15.0
@export var gravity : float = 50.0

const ANIMATION_BLEND : float = 7.0

@onready var player_mesh : Node3D = $Mesh
@onready var spring_arm_pivot : Node3D = $SpringArmPivot
@onready var animator : AnimationTree = $AnimationTree
@onready var ol_camera: OLCamera = $SpringArmPivot/SpringArm3D/OLCamera

func _ready():
	GameManager._player_camera = ol_camera
	
	DebugManager.debug_mode_changed.connect(_on_debug_mode_changed)

func _physics_process(delta):
	var move_direction : Vector3 = Vector3.ZERO
	move_direction.x = Input.get_action_strength("player_right") - Input.get_action_strength("player_left")
	move_direction.z = Input.get_action_strength("player_backward") - Input.get_action_strength("player_forward")
	move_direction = move_direction.rotated(Vector3.UP, spring_arm_pivot.rotation.y)
	
	velocity.y -= gravity * delta
	
	if Input.is_action_pressed("player_run"):
		speed = run_speed
	else:
		speed = walk_speed
	
	velocity.x = move_direction.x * speed
	velocity.z = move_direction.z * speed
	
	if move_direction:
		player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, atan2(velocity.x, velocity.z), LERP_VALUE)
	
	var just_landed := is_on_floor() and snap_vector == Vector3.ZERO
	var is_jumping := is_on_floor() and Input.is_action_just_pressed("player_jump")
	if is_jumping:
		velocity.y = jump_strength
		snap_vector = Vector3.ZERO
	elif just_landed:
		snap_vector = Vector3.DOWN
	
	apply_floor_snap()
	move_and_slide()
	animate(delta)

func animate(delta):
	if is_on_floor():
		animator.set("parameters/ground_air_transition/transition_request", "grounded")
		
		if velocity.length() > 0:
			if speed == run_speed:
				animator.set("parameters/iwr_blend/blend_amount", lerp(animator.get("parameters/iwr_blend/blend_amount"), 1.0, delta * ANIMATION_BLEND))
			else:
				animator.set("parameters/iwr_blend/blend_amount", lerp(animator.get("parameters/iwr_blend/blend_amount"), 0.0, delta * ANIMATION_BLEND))
		else:
			animator.set("parameters/iwr_blend/blend_amount", lerp(animator.get("parameters/iwr_blend/blend_amount"), -1.0, delta * ANIMATION_BLEND))
	else:
		animator.set("parameters/ground_air_transition/transition_request", "air")

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
