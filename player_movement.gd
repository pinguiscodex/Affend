extends CharacterBody3D

## Speed of the player movement in units per second
@export var speed := 5.0
## Speed when sprinting (multiplied by speed)
@export var sprint_speed_multiplier := 2.0
## Jump velocity in units per second
@export var jump_velocity := 4.5
## Acceleration rate for movement
@export var acceleration_rate := 5.0
## Mouse sensitivity for looking around
@export var mouse_sensitivity := 0.1

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * 10.0
var is_sprinting = false
var rotation_helper = Vector3.ZERO
var mouse_locked = true

func _ready():
	# Hide the mouse cursor and lock it to the center of the screen
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	# Toggle mouse lock with ESC key
	if event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed:
		toggle_mouse_lock()

	# Handle mouse movement for camera rotation if mouse is locked
	if event is InputEventMouseMotion and mouse_locked:
		rotation_helper.x -= event.relative.y * mouse_sensitivity
		rotation_helper.x = clamp(rotation_helper.x, -90, 90)  # Limit vertical look angle
		self.rotation.x = deg_to_rad(rotation_helper.x)

		rotation_helper.y -= event.relative.x * mouse_sensitivity
		self.rotation.y = deg_to_rad(rotation_helper.y)

func _physics_process(delta):
	# Add gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle horizontal movement
	var direction = get_direction_input()

	# Convert the input direction to world space based on player's rotation
	direction = direction.rotated(Vector3.UP, rotation.y)

	# Apply acceleration to reach target velocity
	if direction.length() > 0:
		velocity.x = move_toward(velocity.x, direction.x * speed * get_speed_multiplier(), acceleration_rate)
		velocity.z = move_toward(velocity.z, direction.z * speed * get_speed_multiplier(), acceleration_rate)
	else:
		# Decelerate when no input
		velocity.x = move_toward(velocity.x, 0, acceleration_rate)
		velocity.z = move_toward(velocity.z, 0, acceleration_rate)

	# Handle jumping
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	move_and_slide()

func get_direction_input():
	# Get input for movement direction
	var input_dir = Vector3.ZERO
	input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_dir.z = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	return input_dir.normalized()

func get_speed_multiplier():
	# Check if sprinting
	is_sprinting = Input.is_action_pressed("sprint")
	return sprint_speed_multiplier if is_sprinting else 1.0

func toggle_mouse_lock():
	mouse_locked = !mouse_locked
	if mouse_locked:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
