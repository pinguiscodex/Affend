class_name PlayerMovement extends CharacterBody3D

## Speed of the player movement in units per second
@export var speed := 5.0
## Speed when sprinting (multiplied by speed)
@export var sprint_speed_multiplier := 2.0
## Jump velocity in units per second
@export var jump_velocity := 4.5
## Acceleration rate for movement
@export var acceleration_rate := 5.0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * 10.0
var is_sprinting = false

func _ready():
	# Called when the node enters the scene tree for the first time
	pass

func _physics_process(delta):
	# Add gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle horizontal movement
	var direction = get_direction_input()
	
	# Apply acceleration to reach target velocity
	if direction.length() > 0:
		velocity.x = move_toward(velocity.x, direction.x * speed * get_speed_multiplier(), acceleration_rate)
		velocity.z = move_toward(velocity.z, direction.z * speed * get_speed_multiplier(), acceleration_rate)
	else:
		# Decelerate when no input
		velocity.x = move_toward(velocity.x, 0, acceleration_rate)
		velocity.z = move_toward(velocity.z, 0, acceleration_rate)

	# Handle jumping
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	move_and_slide()

func get_direction_input():
	# Get input for movement direction
	var input_dir = Vector3.ZERO
	input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_dir.z = Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	return input_dir.normalized()

func get_speed_multiplier():
	# Check if sprinting
	is_sprinting = Input.is_action_pressed("sprint")
	return sprint_speed_multiplier if is_sprinting else 1.0