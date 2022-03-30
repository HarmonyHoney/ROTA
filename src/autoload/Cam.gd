extends Camera2D

signal turning(angle)

var target_node
onready var target_pos := position
var is_rotating := true
var is_moving := true

var screen_size := Vector2(1280, 720)
onready var start_offset = offset

var turn_clock := 0.0
var turn_time := 0.5
var turn_from := 0.0
var turn_to := 0.0

var is_zoom := false
var zoom_clock := 0.0
var zoom_time := 0.5
var zoom_from := 1.0
var zoom_to := 1.0
var zoom_out := 2.5

func _process(delta):
	# rotation
	if is_rotating:
		turn_clock = min(turn_clock + delta, turn_time)
		
		var s = smoothstep(0, 1, turn_clock / turn_time)
		rotation = lerp_angle(turn_from, turn_to, s)
		emit_signal("turning", rotation)
		
		if start_offset != Vector2.ZERO:
			offset = start_offset.rotated(rotation)
	
	# track target
	if is_instance_valid(target_node):
		target_pos = target_node.global_position
	
	# position
	if is_moving:
		global_position = global_position.linear_interpolate(target_pos, 0.08)
	
	# zoom
	if is_zoom:
		zoom_clock = min(zoom_clock + delta, zoom_time)
		var s = smoothstep(0, 1, zoom_clock / zoom_time)
		
		zoom = Vector2.ONE * lerp(zoom_from, zoom_to, s)
		if zoom_clock == zoom_time:
			is_zoom = false

func turn(arg):
	turn_from = rotation
	turn_to = arg
	turn_clock = 0.0

func start_zoom(arg := 0.0):
	var z = zoom_to
	zoom_to = lerp(1.0, zoom_out, arg)
	
	if zoom_to != z:
		is_zoom = true
		zoom_from = zoom.x
		zoom_clock = 0.0

