tool
extends Camera2D

var target_angle := 0.0
var rotation_weight := 1.8
signal set_rotation(degrees)

var zoom_multiplier := 4.0
onready var start_zoom := zoom
onready var zoom_out := zoom * zoom_multiplier
var zoom_clock := 0.0
var zoom_duration := 1.5

var target_node
onready var start_position := position
export var is_rotating := true
export var is_moving := false
export var is_focal_point := false
export var focal_influence := 0.25
export var is_focal_zoom := false
export var focal_zoom_threshhold := 500 setget set_threshhold
export var focal_zoom_dividend := 1000
export var is_zoom_out := true

var screen_size := Vector2(1280, 720)
onready var size = start_zoom * screen_size.y

onready var start_offset = offset

func _ready():
	if Shared.is_level_select:
		zoom_clock = zoom_duration

func _process(delta):
	if Engine.editor_hint: return
	
	# rotation
	if is_rotating:
		rotation = lerp_angle(rotation, deg2rad(target_angle), rotation_weight * delta)
		emit_signal("set_rotation", rotation_degrees)
		
		if start_offset != Vector2.ZERO:
			offset = start_offset.rotated(rotation)
	
	# zoom in
	if zoom_clock != zoom_duration:
		zoom_clock = min(zoom_clock + delta, zoom_duration)
		zoom = zoom_out.linear_interpolate(start_zoom, zoom_clock / zoom_duration)
	
	# position
	if is_instance_valid(target_node):
		if is_moving:
			if is_focal_point:
				position = start_position + ((target_node.position - start_position) * focal_influence)
			else:
				position = target_node.position
		if is_focal_zoom and zoom_clock == zoom_duration:
			var dist = abs(start_position.distance_to(target_node.position))
			if dist < focal_zoom_threshhold:
				zoom = start_zoom
			else:
				zoom = start_zoom + Vector2.ONE * ((dist - focal_zoom_threshhold) / focal_zoom_dividend)
		
		# keep target on screen
		if is_zoom_out and !is_focal_zoom and zoom_clock == zoom_duration:
			var dist = position.distance_to(target_node.position)
			if dist + 50 < size.y / 2:
				zoom = start_zoom
			else:
				zoom = Vector2.ONE * ((dist + 50) / (screen_size.y / 2))
		


func _draw():
	if !Engine.editor_hint: return
	#draw_circle(Vector2.ZERO, focal_zoom_threshhold, Color(0,0,0, 0.1))
	if is_focal_zoom:
		draw_arc(Vector2.ZERO, focal_zoom_threshhold, 0, TAU, 33, Color(1,0,0, 0.2), 5.0)
	
	var size = zoom * screen_size.y
	draw_rect(Rect2(-size * 0.5, size), Color(1,0,0, 0.2), false, 10.0)

func set_threshhold(arg):
	focal_zoom_threshhold = abs(arg)
	update()

