extends CharacterBody3D

@onready var path: Path3D = $"../mobius_path"
@onready var pathFollow: PathFollow3D = $"../mobius_path/PathFollow3D"
@onready var label: Label3D = $"../Camera3D/Label3D"
@onready var label_controls: Label3D = $"../Camera3D/Label3D2"
@onready var camera: Camera3D = $"../Camera3D"

const SPEED := 8.0
const JUMP_VELOCITY := 4.5
const MOUSE_SENS := 1.0

var inMenu: bool = false
var cam_local: bool = true
var cam_distance: float = 3.0
var cam_height_when2D: float = 0.75

var vert_projection: float

var s: float = 0.0
var s_velocity: float = 0.0
var s_forces: float = 0.0

var h: float = 0.0
var h_vel: float = 0.0
var h_forces: float = 0.0
var thickness: float = 0.1 # Manually set this equal to thickness from the mobius_path script!

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event: InputEvent) -> void:
	### Rotate camera w/ mouse
	if event is InputEventMouseMotion and !inMenu and !cam_local:
		camera.rotation.y -= event.relative.x * MOUSE_SENS/180.0
		camera.rotation.y = wrapf(camera.rotation.y, 0.0, 2*PI)
		camera.rotation.x -= event.relative.y * MOUSE_SENS/180.0
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
	
	### Handle mouse capture with ESC
	if event.is_action_pressed('ui_cancel'):
		if inMenu:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		inMenu = !inMenu
	
	### Toggle camera local/global
	if event.is_action_pressed('toggle_cam'):
		cam_local = !cam_local
		if !cam_local:
			camera.rotation = Vector3.ZERO
	
	### Zoom in and out
	if event.is_action_pressed('zoom_in') and !cam_local:
		cam_distance -= 0.5
	if event.is_action_pressed('zoom_out') and !cam_local:
		cam_distance += 0.5
	cam_distance = clampf(cam_distance, 0.0, 20.0)


func _physics_process(dt: float) -> void:
	### Add gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta
	### Handle jump.
	#if Input.is_action_just_pressed("jump"):# and is_on_floor():
		#velocity.y = JUMP_VELOCITY
	
	## Movement along the mobius strip
	var F_gravity: Vector3
	var input_LR: float = Input.get_axis('left', 'right')
	var path_length: float = path.curve.get_baked_length()
	var parity: int
	
	s_forces = (input_LR * SPEED) + (-4.0 * s_velocity)
	s_velocity += dt * s_forces/1.0 # Dividing by mass (1.0 kg)
	s += dt * s_velocity
	
	### Process player position & rotation on the strip
	pathFollow.progress = fmod(s,path_length)
	position = pathFollow.position
	basis = path.curve.sample_baked_with_rotation(pathFollow.progress,true,true).basis
	
	parity = -2 * ( int(s/path_length)%2 + ((1-sign(s))/2) ) + 1
	if parity == 0:
		parity = 1
	basis.y = parity * basis.y
	basis.x = parity * basis.x
	basis = basis.rotated(basis.x, PI/2)
	basis = basis.rotated(-basis.z, PI/2)
	
	### Player gravity & jump
	var ground_offset := -basis.y * thickness * 3.5
	position = position + ground_offset
	if is_zero_approx(h):
		h_forces = 0
	else:
		h_forces = -9.8
	if Input.is_action_just_pressed('jump'):
		h_vel += 3
	h_vel += h_forces * dt
	h += h_vel * dt
	h = clampf(h, 0.0, thickness * 7)
	
	var jump_offset := h*basis.y
	position = position + jump_offset
	
	### Debug tools
	if !cam_local:
		label.font_size = 256/cam_distance
		label.pixel_size = 0.0001
		label.text = String( 's: ' + String.num(s,2) + '\nprogress_ratio: ' + String.num(pathFollow.progress_ratio,3) + '\nparity: ' + String.num(parity,0))
		DebugDraw3D.draw_arrow_ray(position, basis.z, 0.75, Color.BLUE, 0.05)
		DebugDraw3D.draw_arrow_ray(position, basis.y, 0.75, Color.GREEN, 0.05)
		DebugDraw3D.draw_arrow_ray(position, basis.x, 0.75, Color.RED, 0.05)
		
		label_controls.font_size = 64
		label_controls.pixel_size = 0.0001
		label_controls.horizontal_alignment = 0
		label_controls.text = String('Full Controls:\n[A]/[D]: Move \"left\"/\"right\"\n[Space]: Jump\n[T]: Toggle view\n[O]/[P]: Zoom out/in\n[Mouse]: Rotate camera')
	if cam_local:
		label.text = String()
		label_controls.font_size = 64
		label_controls.pixel_size = 0.0001
		label_controls.horizontal_alignment = 0
		label_controls.text = String('Controls:\n[A]/[D]: Move left/right\n[Space]: Jump\n[T]: Toggle view')
	
	### Process position of external camera
	camera.position = ( (1-float(cam_local))*camera.basis.z*(cam_distance) ) + ( float(cam_local)*(position+cam_height_when2D*basis.z-ground_offset-jump_offset) )
	if cam_local:
		camera.basis = basis
	
	## 3D floating movement
	#var input_dir := Input.get_vector("left", "right", "forward", "backward")
	#vert_projection = Input.get_axis('lowering', 'raising')
	#var direction := (transform.basis * Vector3(input_dir.x, vert_projection, input_dir.y)).normalized()
	#if direction:
		#velocity = direction * SPEED
	#else:
		#velocity = velocity.move_toward(Vector3.ZERO, SPEED)
	
	#move_and_slide()
