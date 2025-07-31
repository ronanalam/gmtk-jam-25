extends Path3D

@export var count: int
@export var radius: float
@export var stripWidth: float
@export var stripThickness: float

func _ready() -> void:
	curve.clear_points()
	
	for i in range(count):
		var point_position_i := radius*Vector3( cos(2*PI*i/count), sin(2*PI*i/count), -3.0/radius )
		
		curve.add_point( point_position_i )
		curve.set_point_tilt(i, PI * i/count)
		curve.set_point_position( i, point_position_i + (stripWidth * i/count)*Vector3.FORWARD )
		
		# Make duplicated point at the end, but with 0 tilt
		# to make the automatic "closing" extrusion unflipped
		if i == (count - 1):
			curve.add_point( point_position_i )
			curve.set_point_tilt(i+1, curve.get_point_tilt(0))
			curve.set_point_position(i+1, point_position_i + (stripWidth * i/count)*Vector3.FORWARD )


#func _process(delta: float) -> void:
	#pass
