extends CanvasLayer

onready var gem_label : Label = $Control/Gems/Label

onready var reset_spinner := $Control/Top/Reset/Spinner
onready var reset_cirlce := $Control/Top/Reset/Circle
var is_reset := false
var btn_reset := false

onready var zoom_notch := $Control/Top/Zoom/Slider/Notch
onready var zoom_circle := $Control/Top/Zoom/Circle
var zoom_step := 0
var zoom_steps := 3
var zoom_from := 0.0
var zoom_to := 0.0

var gem = EaseMover.new()
var top = EaseMover.new()
var reset = EaseMover.new()
var menu = EaseMover.new()
var zoom = EaseMover.new()

func _ready():
	gem_label.text = str(Shared.gem_count)
	
	gem.node = $Control/Gems
	gem.to = gem.node.rect_position
	gem.from = gem.to - Vector2(0, 120)
	gem.show = false
	
	top.node = $Control/Top
	top.to = top.node.rect_position
	top.from = top.to - Vector2(0, 125)
	
	reset.time = 1.0
	
	zoom.time = 0.25
	zoom_circle.scale = Vector2.ZERO
	
	menu.node = $Control/Menu
	menu.to = menu.node.rect_position
	menu.from = menu.to + Vector2(0, 80)
	menu.show = false

func _input(event):
	if event.is_action_pressed("zoom"):
		set_zoom(zoom_step + 1)

func _physics_process(delta):
	gem.move(delta)
	top.move(delta)
	menu.move(delta)
	
	if zoom.clock != zoom.time:
		zoom.count(delta)
		zoom_circle.scale = Vector2.ONE * lerp(zoom_from, zoom_to, zoom.frac())
		
	
	# reset
	if is_reset:
		is_reset = Input.is_action_pressed("reset")
	else:
		is_reset = Input.is_action_just_pressed("reset")
	
	var rs = reset.count(delta, is_reset)
	reset_spinner.rotation = lerp(0, TAU, rs)
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
	
	zoom_from = zoom_circle.scale.x
	zoom_to = lerp(0.0, 1.0, zf)
	zoom.clock = 0
	
	Cam.start_zoom(zf)
	
