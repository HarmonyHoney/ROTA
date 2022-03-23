extends CanvasLayer

var controls = {}

onready var gems := $Control/Gems
onready var gem_label : Label= $Control/Gems/Label

var is_gem := false
var gem_clock := 0.0
var gem_time := 0.5

var gem_from := Vector2(0, -120)
var gem_to := Vector2.ZERO

func _ready():
	for i in $GameControls.get_children():
		controls[i.name.to_lower()] = i
	show()
	
	gem_label.text = str(Shared.gem_count)

func _physics_process(delta):
	gem_clock = clamp(gem_clock + (delta if is_gem else -delta), 0, gem_time)
	var s = smoothstep(0, 1, gem_clock / gem_time)
	gems.rect_position = gem_from.linear_interpolate(gem_to, s)

func show(arg := "none"):
	for i in controls.values():
		i.visible = false
	
	if controls.has(arg.to_lower()):
		controls[arg.to_lower()].visible = true
