extends Camera2D

var target_angle := 0.0
var rotation_weight := 1.8

signal set_rotation(degrees)

func _process(delta):
	rotation = lerp_angle(rotation, deg2rad(target_angle), rotation_weight * delta)
	emit_signal("set_rotation", rotation_degrees)
