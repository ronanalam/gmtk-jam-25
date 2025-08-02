extends Path3D

@onready var mobius_polygon: CSGPolygon3D = $mobius_polygon

@export var points: int
@export var radius: float
@export var z_position: float
@export var stripWidth: float
@export var stripThickness: float
@export var twists: int


func _ready() -> void:
	configure_polygon(mobius_polygon, stripWidth, stripThickness)
	
	curve.clear_points()
	generate_segments(points, radius)


func generate_segments(num_segments: int, r: float) -> void:
	var handle_length := (4.0/3.0)*tan(PI/(2*num_segments))
	
	for i in range(num_segments+1):
		var frac := float(i)/float(num_segments)
		var point_position_i := Vector3( r*cos(2*PI*frac), r*sin(2*PI*frac), z_position )
		var tangent_direction_i := Vector3( -point_position_i.y, point_position_i.x, 0.0 ) * (1/r)
		var in_position_i := r * handle_length * -tangent_direction_i
		var out_position_i := r * handle_length * tangent_direction_i
		
		curve.add_point(point_position_i, in_position_i, out_position_i)
		curve.set_point_tilt(i, twists * PI * i/num_segments)


func configure_polygon(polygon: CSGPolygon3D, width: float, thickness: float):
	var fill_shape := Array(mobius_polygon.polygon)
	fill_shape[0] = Vector2(-width/2.0, thickness/2.0)
	fill_shape[1] = Vector2(-width/2.0, -thickness/2.0)
	fill_shape[2] = Vector2(width/2.0, -thickness/2.0)
	fill_shape[3] = Vector2(width/2.0, thickness/2.0)
	
	polygon.set_polygon(PackedVector2Array(fill_shape))

#func _process(delta: float) -> void:
	#pass

#func _physics_process(delta: float) -> void:
	#curve.clear_points()
	#generate_segments(points, radius)
