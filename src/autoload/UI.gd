extends CanvasLayer

class Mover:
	var show := true
	var clock := 0.0
	var time := 0.5
	var from := Vector2.ZERO
	var to := Vector2.ZERO
	var node
	
	func count(delta, arg := show):
		clock = clamp(clock + (delta if arg else -delta), 0, time)
		return smoothstep(0, 1, clock / time)
	
	func move(delta):
		var s = count(delta)
		node.rect_position = from.linear_interpolate(to, s)

var gem = Mover.new()
var top = Mover.new()
var bottom = Mover.new()
var reset = Mover.new()

onready var gem_label : Label = $Control/Gems/Label

onready var reset_spinner := $Control/Top/Reset/Spinner
onready var reset_cirlce := $Control/Top/Reset/Circle
var is_reset := false
var btn_reset := false

onready var zoom := $Control/Top/Zoom
onready var zoom_notch := $Control/Top/Zoom/Slider/Notch
var zoom_step := 0
var zoom_steps := 3

onready var dpad_spin := $Control/Bottom/DPad/Spin

func _ready():
	gem_label.text = str(Shared.gem_count)
	
	gem.node = $Control/Gems
	gem.to = gem.node.rect_position
	gem.from = gem.to - Vector2(0, 120)
	gem.show = false
	
	top.node = $Control/Top
	top.to = top.node.rect_position
	top.from = top.to - Vector2(0, 125)
	
	bottom.node = $Control/Bottom
	bottom.to = bottom.node.rect_position
	bottom.from = bottom.to + Vector2(0, 200)
	
	

func _input(event):
	if event.is_action_pressed("zoom_out"):
		set_zoom(zoom_step + 1)

func _physics_process(delta):
	gem.move(delta)
	top.move(delta)
	bottom.move(delta)
	
	# reset
	if is_reset:
		is_reset = Input.is_action_pressed("reset")
	else:
		is_reset = Input.is_action_just_pressed("reset")
	
	var rs = reset.count(delta, is_reset)
	reset_spinner.rotation = lerp(0, PI, rs)
	reset_cirlce.scale = Vector2.ONE * rs
	
	if reset.clock == reset.time:
		is_reset = false
		Shared.reset()
		if is_instance_valid(Shared.player):
			Shared.player.set_physics_process(false)

func set_zoom(arg := 0):
	zoom_step = posmod(arg, zoom_steps + 1)
	var zf = float(zoom_step) / zoom_steps
	zoom_notch.position.y = lerp(8, 56, zf)
	
	Cam.start_zoom(zf)
	
