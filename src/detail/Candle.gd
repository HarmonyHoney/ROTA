tool
extends Node2D

onready var circle := $Sprites/Circle

var t := 0.0

onready var sprites := $Sprites


var angle := 0.0
var velocity := 0.0
var target := 0.0

export var add_vel := 6.0
export var weight := 2.0

var cooldown_clock := 0.0
export var cooldown_time := 0.6


func _physics_process(delta):
	#if Engine.editor_hint: return
	
	# light
	
	t += delta
	
	if circle:
		var s = 1.0 + (sin(t * 1.5) * 0.1)
		circle.scale = Vector2.ONE * s
	
	
	# spring
	if Engine.editor_hint: return
	
	velocity = lerp(velocity, (target - angle) * 0.5, delta * weight)
	angle += velocity
	sprites.rotation_degrees = angle
	
	# cooldown
	cooldown_clock = max(cooldown_clock - delta, 0)

func _on_Area2D_body_entered(body):
	if cooldown_clock == 0:
		hit(1 if to_local(body.global_position).x < 0 else -1)
		cooldown_clock = cooldown_time

func hit(scale := 1.0):
	velocity += add_vel * scale
