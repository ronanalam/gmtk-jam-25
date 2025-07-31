extends CharacterBody3D

const SPEED := 2.0
const JUMP_VELOCITY := 4.5
const MOUSE_SENS := 1.0

var vert_projection: float


func _unhandled_input(event: InputEvent) -> void:
	### Rotate camera w/ mouse
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x * MOUSE_SENS/180.0
		rotation.y = wrapf(rotation.y, 0.0, 2*PI)
		rotation.x -= event.relative.y * MOUSE_SENS/180.0
		rotation.x = clamp(rotation.x, -PI/2, PI/4)


func _physics_process(delta: float) -> void:
	### Add gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta
	### Handle jump.
	#if Input.is_action_just_pressed("jump"):# and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	vert_projection = Input.get_axis('lowering', 'raising')
	var direction := (transform.basis * Vector3(input_dir.x, vert_projection, input_dir.y)).normalized()
	if direction:
		velocity = direction * SPEED
	else:
		velocity = velocity.move_toward(Vector3.ZERO, SPEED)
	
	move_and_slide()
