extends Camera2D

signal turning(angle)

var target_node setget set_target_node
onready var target_pos := global_position
var is_rotating := true
var is_moving := true

var screen_size := Vector2(1280, 720)
export var turn_offset := Vector2.ZERO

var turn_ease := EaseMover.new()
var turn_from := 0.0
var turn_to := 0.0

var is_zoom := false

var zoom_ease := EaseMover.new()
var zoom_from := 1.0
var zoom_to := 1.0

export var zoom_min := 1.33
export var zoom_max := 2.5

var zoom_step := 0
var zoom_steps := 2

var rot_offset := Vector2.ZERO

var is_pan := false
var pan_ease := EaseMover.new(1.0)
signal pan_complete


func _enter_tree():
	Shared.connect("scene_changed", self, "scene_changed")

func _ready():
	zoom = Vector2.ONE * zoom_min

func _input(event):
	if event.is_action_pressed("zoom") and !Wipe.is_wipe and !Cutscene.is_playing and !MenuMakeover.is_open and "world" in Shared.csfn:
		start_zoom(zoom_step + 1)

func _process(delta):
	# zoom
	if is_zoom:
		zoom = Vector2.ONE * lerp(zoom_from, zoom_to, zoom_ease.count(delta))
		if zoom_ease.is_complete:
			is_zoom = false
	
	# rotation
	if is_rotating:
		if turn_ease.clock < turn_ease.time:
			rotation = lerp_angle(turn_from, turn_to, turn_ease.count(delta))
			emit_signal("turning", rotation)
	
	if is_pan:
		global_position = pan_ease.move(delta)
		if pan_ease.is_complete:
			emit_signal("pan_complete")
			#print("pan_complete")
			is_pan = false
	else:
		# track target
		if is_instance_valid(target_node):
			target_pos = target_node.global_position
		
		# position
		if is_moving:
			global_position = global_position.linear_interpolate(target_pos + turn_offset.rotated(rotation), 0.08)

func set_target_node(arg):
	if is_instance_valid(target_node): target_node.disconnect("turn_cam", self, "turn")
	target_node = arg
	if is_instance_valid(target_node) and target_node.has_signal("turn_cam"): target_node.connect("turn_cam", self, "turn")
	

func turn(arg):
	turn_from = rotation
	turn_to = arg
	turn_ease.clock = 0.0

func start_zoom(arg := 0, is_audio := true, _zmin = zoom_min, _zmax = zoom_max):
	zoom_step = posmod(arg, zoom_steps + 1)
	
	is_zoom = true
	zoom_ease.clock = 0.0
	zoom_from = zoom.x
	var frac = float(zoom_step) / zoom_steps
	zoom_to = lerp(_zmin, _zmax, frac)
	
	if is_audio:
		Audio.play("cam_zoom", 0.8, 1.2)

func reset_zoom():
	is_zoom = false
	zoom_step = 0
	zoom = Vector2.ONE * zoom_min
	zoom_to = zoom_min

func scene_changed():
	if is_instance_valid(target_node):
		snap_to(target_node.global_position, target_node.turn_to)

func snap_to(pos, turn):
	global_position = pos
	target_pos = pos
	turn_from = turn
	turn_to = turn
	rotation = turn
	turn_ease.clock = 99
	reset_smoothing()
	force_update_scroll()
	force_update_transform()

func pan(pos : Vector2):
	pan_ease.clock = 0
	is_pan = true
	target_pos = pos
	pan_ease.from = global_position
	pan_ease.to = target_pos
	pan_ease.time = lerp(0.3, 1.0, clamp(pan_ease.from.distance_to(pan_ease.to) / 100.0, 0, 20) / 20)
