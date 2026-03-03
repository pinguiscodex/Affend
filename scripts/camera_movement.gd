extends Camera3D

# Exported variables for mouse sensitivity
@export var sens_horizontal: float = 0.3
@export var sens_vertical: float = 0.3

# Minimum and maximum angles for camera pitch (looking up and down)
@export var min_pitch: float = -90.0
@export var max_pitch: float = 90.0

# Variables for camera rotation
var pitch: float = 0.0

func _ready() -> void:
	# Set mouse mode to captured (locked and invisible)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	# Toggle mouse mode between visible and captured when ESC is pressed
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		return
	
	# Handle camera movement based on mouse motion only if the mouse is captured
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and event is InputEventMouseMotion:
		var mouse_event = event as InputEventMouseMotion
		
		# Rotate horizontally (yaw) - turn the character left/right
		get_parent().rotate_y(-mouse_event.relative.x * sens_horizontal * deg_to_rad(1))
		
		# Adjust pitch (look up/down) and clamp it
		pitch -= mouse_event.relative.y * sens_vertical
		pitch = clamp(pitch, min_pitch, max_pitch)
		rotation_degrees.x = pitch
