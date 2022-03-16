extends Node2D

export var sprites_path : NodePath
onready var sprites := get_node(sprites_path)
export var is_scale := false
var angle := 0.0
var velocity := 0.0
var target := 0.0

export var add_vel := 6.0
export var weight := 2.0

var cooldown_clock := 0.0
export var cooldown_time := 0.6

export var audio_path : NodePath
onready var audio_hit := get_node(audio_path)
export var pitch_from := 0.7
export var pitch_to := 1.3


func _physics_process(delta):
	velocity = lerp(velocity, (target - angle) * 0.5, delta * weight)
	angle += velocity
	
	if sprites:
		if is_scale:
			sprites.scale = Vector2.ONE + (Vector2.ONE * angle)
		else:
			sprites.rotation_degrees = angle
	
	# cooldown
	cooldown_clock = max(cooldown_clock - delta, 0)

func hit(scale := 1.0):
	velocity += add_vel * scale
	
	if audio_hit:
		audio_hit.pitch_scale = rand_range(pitch_from, pitch_to)
		audio_hit.play()

func _on_Area2D_area_entered(area):
	if cooldown_clock == 0:
		hit(1 if to_local(area.global_position).x < 0 else -1)
		cooldown_clock = cooldown_time
