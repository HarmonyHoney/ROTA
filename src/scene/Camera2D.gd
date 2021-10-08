extends Camera2D


var target_angle := 0.0
var rotation_weight := 0.03

signal set_rotation(degrees)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	rotation = lerp_angle(rotation, deg2rad(target_angle), rotation_weight)
	emit_signal("set_rotation", rotation_degrees)
