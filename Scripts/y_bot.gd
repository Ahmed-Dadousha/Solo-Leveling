extends CharacterBody3D

@onready var animation_player: AnimationPlayer = $"visuals/Root Scene/AnimationPlayer"
@onready var visuals: Node3D = $visuals

const SPEED = 4.0
const MAX_SPEED: int = 7
const JUMP_VELOCITY = 4.5
const SENS_HORIZONTAL: float = .5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var is_running: bool = false

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * SENS_HORIZONTAL))
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
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if is_running:
		# Get new run direction
		var  run_direction = (transform.basis * Vector3(0, 0,-1)).normalized()
		if animation_player.current_animation != "RunningWithoutWeapon/mixamo_com":
			animation_player.play("RunningWithoutWeapon/mixamo_com")
			
		velocity.x = run_direction.x * MAX_SPEED
		velocity.z = run_direction.z * MAX_SPEED
		visuals.look_at(position + run_direction)
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
