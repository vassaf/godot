extends CharacterBody3D

@onready var camera_mount: Node3D = $CameraMount
@onready var animation_player: AnimationPlayer = $Visuals/char/AnimationPlayer
@onready var visuals: Node3D = $Visuals

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const CAMERA_SENSIVITY = 0.5
const CAMERA_SENSIVITY_Y = 0.1
const TURN_SPEED = 10.0  # Adjust to control turning smoothness

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * CAMERA_SENSIVITY))
		camera_mount.rotate_x(deg_to_rad(-event.relative.y * CAMERA_SENSIVITY_Y))

func _physics_process(delta: float) -> void:
	# Add gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get input direction and handle movement.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		animation_player.play("mixamo_com")

		# Get the target rotation
		var target_rotation = visuals.global_transform.basis.get_rotation_quaternion()
		var desired_rotation = Quaternion().from_euler(Vector3(0, atan2(-direction.x, -direction.z), 0))
		
		# Smoothly interpolate between current and desired rotation
		target_rotation = target_rotation.slerp(desired_rotation, TURN_SPEED * delta)

		# Apply the rotation
		visuals.global_transform.basis = Basis(target_rotation)

		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		animation_player.stop()
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
