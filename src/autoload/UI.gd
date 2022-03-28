extends CanvasLayer

var is_gem := false
var gem_clock := 0.0
var gem_time := 0.5

onready var gems := $Control/Gems
onready var gem_label : Label= $Control/Gems/Label
onready var gem_to : Vector2 = gems.rect_position
onready var gem_from := Vector2(gem_to.x, -120)

onready var reset := $Control/Reset
onready var reset_spinner := $Control/Reset/Spinner
onready var reset_cirlce := $Control/Reset/Circle
onready var reset_to : Vector2 = reset.rect_position
onready var reset_from := Vector2(reset_to.x, -120)

var is_reset := false
var btn_reset := false
var reset_clock := 0.0
var reset_time := 1.0

onready var zoom := $Control/Zoom
onready var zoom_notch := $Control/Zoom/Slider/Notch

onready var dpad_spin := $Control/DPad/Spin

func _ready():
	gem_label.text = str(Shared.gem_count)

func _physics_process(delta):
	# gem
	gem_clock = clamp(gem_clock + (delta if is_gem else -delta), 0, gem_time)
	var s = smoothstep(0, 1, gem_clock / gem_time)
	gems.rect_position = gem_from.linear_interpolate(gem_to, s)
	
	# reset
	
	if is_reset:
		is_reset = Input.is_action_pressed("reset")
	else:
		is_reset = Input.is_action_just_pressed("reset")
	
	reset_clock = clamp(reset_clock + (delta if is_reset else -delta), 0, reset_time)
	var rs = smoothstep(0, 1, reset_clock / reset_time)
	reset_spinner.rotation = lerp(0, PI, rs)
	reset_cirlce.scale = Vector2.ONE * rs
	
	if reset_clock == reset_time:
		is_reset = false
		Shared.reset()
		if is_instance_valid(Shared.player):
			Shared.player.set_physics_process(false)

func set_zoom(arg):
	zoom_notch.position.y = lerp(8, 56, arg)
