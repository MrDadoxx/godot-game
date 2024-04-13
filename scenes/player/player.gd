extends CharacterBody3D

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var feet = $Feet
@onready var footstep_player = $Footsteps
@onready var hut_door = get_parent().get_parent().get_node("Stage/Hut/hut/door")
const WALK_SPEED = 5.0
const SPRINT_SPEED = 6.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.008
const BOB_FREQ = 2.0
const BOB_AMP = 0.1
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5
const SPRINT_PITCH = [1.1, 1.3]
const WALK_PITCH = [0.8, 1]

var footstep_pitch = WALK_PITCH
var footstep_sound = null
var speed
var t_bob = 0.0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var is_moving = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(60))

func _physics_process(delta):
	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Sprint
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
		footstep_pitch = SPRINT_PITCH
	else:
		speed = WALK_SPEED
		footstep_pitch = WALK_PITCH

	# Movement
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	is_moving = direction != Vector3.ZERO
	if is_on_floor():
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed

	if is_moving and footstep_sound != null and !footstep_player.is_playing():
		footstep_player.pitch_scale = randf_range(footstep_pitch[0], footstep_pitch[1])
		footstep_player.volume_db = randf_range(0.5, 0.8)
		footstep_player.stream = footstep_sound
		footstep_player.play()
	elif !is_moving:
		footstep_player.stop()

	# Head Bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)

	# Fov
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)

	move_and_slide()

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	return pos

func _on_feet_body_entered(body):
	if "foot_sound" in body:
		footstep_sound = body.foot_sound

func _on_feet_body_exited(body):
	if "foot_sound" in body:
		footstep_sound = null

func _on_door_entered(teleport_position, teleport_rotation, scene_to_go):
	print("1: ", position, " - ", rotation)
	get_tree().change_scene_to_packed(scene_to_go)
	print("2: ", position, " - ", rotation)
	global_transform.origin = teleport_position
