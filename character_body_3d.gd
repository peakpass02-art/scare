extends CharacterBody3D


var speed = 3.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY  = 0.002

const BOB_FREQ = 3.0
const BOB_AMP = 0.08
var t_bob = 0.0

@onready var  head = $head
@onready var cam = $head/Camera3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		cam.rotate_x(-event.relative.y * SENSITIVITY)
		cam.rotation.x = clamp(cam.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Add the gravity.
	if not is_on_floor():
		velocity.y -= 9.0 * delta
	
	if Input.is_action_pressed("run"):
		speed = 7.0
	else:
		speed = 3.0

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backword")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x += direction.x * speed / 10
			velocity.z += direction.z * speed / 10
		else:
			velocity.x = 0.0
			velocity.z = 0.0
	else :
		if direction:
			velocity.x += direction.x * speed / 50
			velocity.z += direction.z * speed / 50
	
	if Input.is_action_just_pressed("stop"):
		pass
	
	t_bob += delta * velocity.length() * float(is_on_floor())
	cam.transform.origin = _headbob(t_bob)
	
	move_and_slide()

func _headbob(_time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(_time * BOB_FREQ) * BOB_AMP
	pos.x = cos(_time * BOB_FREQ  / 2) * BOB_AMP
	return pos
