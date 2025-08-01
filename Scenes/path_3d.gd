extends Path3D

@export var points: int
var count: int
@export var radius: float
@export var z_position: float
@export var stripWidth: float
@export var stripThickness: float

#var point_position_i: Vector3

func _ready() -> void:
	curve.clear_points()
	generate_segments(points, radius)
	
	#for i in range(count+1):
		#var point_position_i := radius*Vector3( cos(2*PI*i/count), sin(2*PI*i/count), -3.0/radius )
		#
		#curve.add_point( point_position_i+ (stripWidth * i/count)*Vector3.FORWARD )
		#curve.set_point_tilt(i, PI * i/count)
		#curve.set_point_position( i, point_position_i + (stripWidth * i/count)*Vector3.FORWARD )
		
		# Make duplicated point at the end, but with 0 tilt
		# to make the automatic "closing" extrusion unflipped
		#if i == (count - 1):
			#curve.add_point( point_position_i )
			#curve.set_point_tilt(i+1, curve.get_point_tilt(i))
			#curve.set_point_position(i+1, point_position_i + (stripWidth * i/count)*Vector3.FORWARD )

func generate_segments(num_segments: int, r: float) -> void:
	for i in range(num_segments):
		var point_position_i := r*Vector3( cos(2*PI*i/num_segments), sin(2*PI*i/num_segments), z_position/r )
		var lateral_offset_i := (stripWidth * i/count)*Vector3.FORWARD
		var tangent_direction_i := Vector3( -point_position_i.y, point_position_i.x, 0.0 )/r
		var in_position_i := -(4.0/3.0) * r * tan(PI/2*num_segments) * tangent_direction_i + z_position*Vector3.BACK
		var out_position_i := (4.0/3.0) * r * tan(PI/2*num_segments) * tangent_direction_i + z_position*Vector3.BACK
		
		curve.add_point(point_position_i + lateral_offset_i, in_position_i, out_position_i)
		
		print(i)
		print(curve.get_point_position(i))

#func _process(delta: float) -> void:
	#pass
