tool
extends Camera2D

signal turning(angle)

var target_node
onready var target_pos := position
export var is_rotating := true
export var is_moving := true

var screen_size := Vector2(1280, 720)
onready var start_offset = offset

var turn_clock := 0.0
var turn_time := 0.5
var turn_from := 0.0
var turn_to := 0.0

export var bg_palette := 0

var is_zoom := false
var zoom_clock := 0.0
var zoom_time := 0.5
var zoom_from := 1.0
var zoom_to := 1.0

func _enter_tree():
	if Engine.editor_hint: return
	Shared.camera = self

func _ready():
	if Engine.editor_hint: return
	BG.set_colors(bg_palette)

func _input(event):
	if event.is_action_pressed("zoom_in") or event.is_action_pressed("zoom_out"):
		start_zoom(0.5 if event.is_action_pressed("zoom_out") else -0.5)

func _process(delta):
	if Engine.editor_hint: return
	
	# rotation
	if is_rotating:
		turn_clock = min(turn_clock + delta, turn_time)
		
		var s = smoothstep(0, 1, turn_clock / turn_time)
		rotation = lerp_angle(turn_from, turn_to, s)
		emit_signal("turning", rotation)
		
		if start_offset != Vector2.ZERO:
			offset = start_offset.rotated(rotation)
	
	if PauseMenu.is_paused:
		if is_instance_valid(target_node):
			position = target_node.position + (Vector2(-200, 0) * zoom).rotated(rotation)
	else:
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

func start_zoom(arg):
	var z = zoom_to
	zoom_to = clamp(zoom_to + arg, 1.0, 2.5)
	
	if zoom_to != z:
		is_zoom = true
		zoom_from = zoom.x
		zoom_clock = 0.0

