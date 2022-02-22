tool
extends Camera2D

signal turning(angle)

var zoom_multiplier := 2.5
onready var start_zoom := zoom
onready var zoom_out := zoom
var zoom_clock := 0.0
var zoom_duration := 1.5

var target_node
onready var start_position := position
export var is_rotating := true
export var is_moving := false
export var is_focal_point := false
export var focal_influence := 0.35
export var is_zoom_out := true

var screen_size := Vector2(1280, 720)
onready var start_offset = offset

export var easing : Curve
var turn_clock := 0.0
var turn_time := 0.5
var turn_from := 0.0
var turn_to := 0.0

var if_is_start_zoom := true

func _ready():
	if Engine.editor_hint: return
	
	Shared.game_camera = self
	
	if !if_is_start_zoom:
		zoom_clock = zoom_duration
	else:
		set_zoom_out()
	
	
#	yield(get_tree(),"idle_frame")
#
#	is_moving = true
#	is_focal_point = false
#	is_zoom_out = false
	

func _process(delta):
	if Engine.editor_hint: return
	
	# zoom in
	zoom_in(delta)
	
	# rotation
	if is_rotating:
		turn_clock = min(turn_clock + delta, turn_time)
		
		rotation = lerp_angle(turn_from, turn_to, easing.interpolate(turn_clock / turn_time))
		emit_signal("turning", rotation)
		
		if start_offset != Vector2.ZERO:
			offset = start_offset.rotated(rotation)
	
	if PauseMenu.is_paused:
		if is_instance_valid(target_node):
			position = target_node.position + (Vector2(-200, 0) * zoom).rotated(rotation)
			#zoom = Vector2.ONE * 1
			
	else:
		# track target
		if is_instance_valid(target_node):
			# position
			if is_moving:
				if is_focal_point:
					position = start_position + ((target_node.position - start_position) * focal_influence)
				else:
					position = target_node.position
			
			# keep target on screen
			if is_zoom_out and zoom_clock == zoom_duration:
				var dist = (position.distance_to(target_node.position) + 100) / (screen_size.y / 2)
				var zoom_dist = Vector2.ONE * dist
				
				zoom = zoom_dist if zoom_dist > start_zoom else start_zoom

func _draw():
	if !Engine.editor_hint: return
	var size = zoom * screen_size.y
	var col = Color(0.3,0,1, 0.2)
	var width = 10
	draw_rect(Rect2(-size / 2, size), col, false, width)
	draw_arc(Vector2.ZERO, size.y / 2, 0, TAU, 33, col, width)

func turn(arg):
	turn_from = rotation
	turn_to = arg
	turn_clock = 0.0

func set_zoom_out():
	var y = start_zoom.y / Shared.start_scale
	zoom_out = Vector2.ONE * y

func zoom_in(delta := 0.0):
	if zoom_clock != zoom_duration:
		zoom_clock = min(zoom_clock + delta, zoom_duration)
		zoom = zoom_out.linear_interpolate(start_zoom, zoom_clock / zoom_duration)
