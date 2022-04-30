extends Camera2D

onready var audio_zoom := $Zoom

signal turning(angle)

var target_node
onready var target_pos := position
var is_rotating := true
var is_moving := true

var screen_size := Vector2(1280, 720)
var turn_offset := Vector2.ZERO

var turn_ease := EaseMover.new()
var turn_from := 0.0
var turn_to := 0.0

var is_zoom := false

var zoom_ease := EaseMover.new()
var zoom_from := 1.0
var zoom_to := 1.0

export var zoom_min := 1.2
export var zoom_max := 2.5

var zoom_step := 0
var zoom_steps := 2

func _ready():
	zoom = Vector2.ONE * zoom_min

func _input(event):
	if event.is_action_pressed("zoom") and !Cutscene.is_playing and "world" in Shared.csfn:
		start_zoom(zoom_step + 1)

func _process(delta):
	# rotation
	if is_rotating:
		if turn_ease.clock < turn_ease.time:
			rotation = lerp_angle(turn_from, turn_to, turn_ease.count(delta))
			emit_signal("turning", rotation)
		
			if turn_offset != Vector2.ZERO:
				offset = turn_offset.rotated(rotation)
	
	# track target
	if is_instance_valid(target_node):
		target_pos = target_node.global_position
	
	# position
	if is_moving:
		global_position = global_position.linear_interpolate(target_pos, 0.08)
	
	# zoom
	if is_zoom:
		zoom = Vector2.ONE * lerp(zoom_from, zoom_to, zoom_ease.count(delta))
		if zoom_ease.is_complete:
			is_zoom = false

func turn(arg):
	turn_from = rotation
	turn_to = arg
	turn_ease.clock = 0.0

func start_zoom(arg := 0, is_audio := true):
	zoom_step = posmod(arg, zoom_steps + 1)
	
	is_zoom = true
	zoom_ease.clock = 0.0
	zoom_from = zoom.x
	var frac = float(zoom_step) / zoom_steps
	zoom_to = lerp(zoom_min, zoom_max, frac)
	
	UI.set_zoom(frac)
	
	if is_audio:
		audio_zoom.pitch_scale = rand_range(0.8, 1.2)
		audio_zoom.play()

func reset_zoom():
	is_zoom = false
	zoom_step = 0
	zoom = Vector2.ONE * zoom_min
	zoom_to = zoom_min
