tool
extends Node2D

onready var sprite := $Sprite

var colors = ["5DFF00", "7ee356", "FFC6E9", "79FFFF", "FFC900"]
export var palette := 0 setget set_palette

var angle := 0.0
var velocity := 0.0
var target := 0.0

export var add_vel := 0.012
export var weight := 8.0

var cooldown_clock := 0.0
export var cooldown_time := 0.8

func _ready():
	set_palette()
	
	# change add_vel from scale
	add_vel *= 1.0 / scale.x

func _physics_process(delta):
	if Engine.editor_hint: return
	
	velocity = lerp(velocity, (target - angle) * 0.5, delta * weight)
	angle += velocity
	sprite.scale = Vector2.ONE + (Vector2.ONE * angle)
	
	# cooldown
	cooldown_clock = max(cooldown_clock - delta, 0)

func set_palette(arg := palette):
	palette = posmod(int(arg), 6)
	if sprite:
		sprite.modulate = Color.white if palette == 0 else Color(colors[palette - 1])

func _on_Area2D_body_entered(body):
	if cooldown_clock == 0:
		hit(1 if randf() > 0.5 else -1)
		cooldown_clock = cooldown_time

func hit(scale := 1.0):
	velocity += add_vel * scale
