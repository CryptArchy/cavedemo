extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var camera = $"CameraEyes"

var camera_rotation = Vector2(0,0)
var mouse_sensitivity = 0.001 # radians

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	if event is InputEventMouseMotion:
		var mouse_event = event.relative * mouse_sensitivity
		camera_look(mouse_event)
			
func camera_look(movement: Vector2):
	camera_rotation += movement
	camera_rotation.y = clamp(camera_rotation.y, -1.5, 1.2)
	
	transform.basis = Basis()
	camera.transform.basis = Basis()
	
	rotate_object_local(Vector3(0,1,0), -camera_rotation.x) # first rotate y
	camera.rotate_object_local(Vector3(1,0,0), -camera_rotation.y) # next rotate x

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("move_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
