tool
extends Node2D

onready var top := $Sprites/TreeTop

var colors = ["5DFF00", "7ee356", "FFC6E9", "79FFFF", "FFC900"]
export var palette := 0 setget set_palette

var angle := 0.0
var velocity := 0.0
var target := 0.0

export var add_vel := 0.025
export var weight := 8.0

var cooldown_clock := 0.0
export var cooldown_time := 0.6

func _ready():
	set_palette()

func _physics_process(delta):
	if Engine.editor_hint: return
	
	velocity = lerp(velocity, (target - angle) * 0.5, delta * weight)
	angle += velocity
	top.scale = Vector2.ONE + (Vector2.ONE * angle)
	
	
	# cooldown
	cooldown_clock = max(cooldown_clock - delta, 0)


func set_palette(arg := palette):
	palette = posmod(int(arg), 6)
	if top:
		top.modulate = Color.white if palette == 0 else Color(colors[palette - 1])

func _on_Area2D_body_entered(body):
	if cooldown_clock == 0:
		hit(1 if randf() > 0.5 else -1)
		cooldown_clock = cooldown_time

func hit(scale := 1.0):
	velocity += add_vel * scale
