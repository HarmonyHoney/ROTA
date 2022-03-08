tool
extends Node2D

onready var sprites := $Sprites
onready var petals := $Sprites/Petals

var colors = ["FF0000", "FF78CB", "79FFFF", "FFFA00", "FFC900"]
export var palette := 1 setget set_palette

var angle := 0.0
var velocity := 0.0
var target := 0.0

export var add_vel := 6.0
export var weight := 2.0

var cooldown_clock := 0.0
export var cooldown_time := 0.6

func _ready():
	petal_color()

func _physics_process(delta):
	if Engine.editor_hint: return
	
	velocity = lerp(velocity, (target - angle) * 0.5, delta * weight)
	angle += velocity
	sprites.rotation_degrees = angle
	
	# cooldown
	cooldown_clock = max(cooldown_clock - delta, 0)

func set_palette(arg):
	palette = posmod(int(arg), 6)
	petal_color()

func petal_color():
	if petals:
		petals.modulate = Color.white if palette == 0 else Color(colors[palette - 1])

func hit(scale := 1.0):
	velocity += add_vel * scale

func _on_Area2D_area_entered(area):
	if cooldown_clock == 0:
		hit(1 if to_local(area.global_position).x < 0 else -1)
		cooldown_clock = cooldown_time
