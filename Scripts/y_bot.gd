extends CharacterBody3D

@onready var animation_player: AnimationPlayer = $"visuals/Root Scene/AnimationPlayer"
@onready var visuals: Node3D = $visuals

const SPEED = 4.0
const MAX_SPEED: int = 7
const JUMP_VELOCITY = 4.5
const SENS: float = .5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var is_running: bool = false

#
@export var speed: float = 5.0
@export var acceleration: float = 4.0
@export var jump_speed: float = 8.0
@export var rotation_speed: float = 12.0
@export var mouse_sensitivity: float = 0.0015

var jumping: bool = false
@onready var spring_arm: SpringArm3D = $SpringArm3D
@onready var rig: Node3D = $visuals


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
		if is_running:
				var tween: Tween = create_tween()
				tween.tween_property(spring_arm, "rotation",Vector3(0,0,0), .2).from_current()
				
		if event is InputEventMouseMotion:
			if is_running:
				rotate_y(deg_to_rad(-event.relative.x * SENS))
			else:
				spring_arm.rotation.x -= event.relative.y * mouse_sensitivity
				spring_arm.rotation_degrees.x = clamp(spring_arm.rotation_degrees.x, -90.0, 30.0)
				spring_arm.rotation.y -= event.relative.x * mouse_sensitivity
				

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Handle Exit
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	
	# Handle Run
	if Input.is_action_just_pressed("run"):
		is_running = !is_running

	# Handle jump.
	#if Input.is_action_just_pressed("jump") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if is_running:
		# Get new run direction
		var  run_direction = (transform.basis * Vector3(0,0,-1)).normalized()
		if animation_player.current_animation != "RunningWithoutWeapon/mixamo_com":
			animation_player.play("RunningWithoutWeapon/mixamo_com")
			
		velocity.x = run_direction.x * MAX_SPEED
		velocity.z = run_direction.z * MAX_SPEED
		visuals.look_at(position + run_direction)
		#visuals.rotation = Vector3($SpringArm3D.rotation.x, $SpringArm3D.rotation.y, 0)
	if direction:
		is_running = false

		if animation_player.current_animation != "WalkingWithoutWeapon/mixamo_com":
			animation_player.play("WalkingWithoutWeapon/mixamo_com")
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		visuals.look_at(position + direction)
		
	elif !direction && !is_running:
		if animation_player.current_animation != "IdleWithoutWeapon/mixamo_com":
			animation_player.play("IdleWithoutWeapon/mixamo_com")
			
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
