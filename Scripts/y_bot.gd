extends CharacterBody3D

@onready var animation_player: AnimationPlayer = $"visuals/Root Scene/AnimationPlayer"
@onready var visuals: Node3D = $visuals

const SPEED: float = 3.0
const MAX_SPEED: int = 6
const JUMP_VELOCITY: float = 4.5
const SENS: float = .6
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var is_running: bool = false
var dir: Vector3
var is_jumping: bool = false
#
@export var mouse_sensitivity: float = 0.0020
@onready var camera_mount = $camera_mount

enum animations {
	IDLE,
	RUN,
	JUMP,
	CROUCH,
	WEAPON_IDLE,
	WEAPON_RUN,
	WEAPON_CROUCH,
	WEAPON_JUMP,
	FIRE}

func _enter_tree():
	# To avoid control other players charcter
	set_multiplayer_authority(str(name).to_int())

func _ready():
	if not is_multiplayer_authority(): return
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	dir = Vector3.BACK.rotated(Vector3.UP, camera_mount.global_transform.basis.get_euler().y)

func _input(event):
		if event is InputEventMouseMotion:
			if is_running:
				rotate_y(deg_to_rad(-event.relative.x * SENS))
				camera_mount.rotation.x -= event.relative.y * mouse_sensitivity
			else:
				camera_mount.rotation.x -= event.relative.y * mouse_sensitivity
				camera_mount.rotation_degrees.x = clamp(camera_mount.rotation_degrees.x, -90.0, 30.0)
				camera_mount.rotation.y -= event.relative.x * mouse_sensitivity				

func _physics_process(delta):
	if not is_multiplayer_authority(): return
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Handle Exit
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	
	# Handle Run
	if Input.is_action_just_pressed("run"):
		is_running = !is_running

	# Handle Jump
	if Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY
		is_jumping = true
		
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if is_running:
		# Get new run direction
		var  run_direction = (transform.basis * Vector3(0,0,-1)).normalized()
		var run_dir = run_direction.rotated(Vector3.UP, camera_mount.transform.basis.get_euler().y).normalized()
		
		if animation_player.current_animation != "RunningWithoutWeapon/mixamo_com":
			animation_player.play("RunningWithoutWeapon/mixamo_com")
			
		velocity.x = run_dir.x * MAX_SPEED
		velocity.z = run_dir.z * MAX_SPEED
		visuals.look_at(position + run_dir)
		
	if direction:
		
		dir = direction.rotated(Vector3.UP, camera_mount.transform.basis.get_euler().y).normalized()
		
		is_running = false

		if animation_player.current_animation != "WalkingWithoutWeapon/mixamo_com":
			animation_player.play("WalkingWithoutWeapon/mixamo_com")
		velocity.x = dir.x * SPEED
		velocity.z = dir.z * SPEED

		visuals.look_at(position + dir)

		
	elif !direction && !is_running && !is_jumping:
		if animation_player.current_animation != "IdleWithoutWeapon/mixamo_com":
			animation_player.play("IdleWithoutWeapon/mixamo_com")
			
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	is_jumping = false
