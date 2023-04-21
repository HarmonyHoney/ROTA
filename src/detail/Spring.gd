extends Node2D

export var sprites_path : NodePath
onready var sprites := get_node_or_null(sprites_path)
export var is_scale := false
var angle := 0.0
var velocity := 0.0
var target := 0.0

export var add_vel := 6.0
export var weight := 2.0

var cooldown_clock := 0.0
export var cooldown_time := 1.0

export var is_audio := false
export var audio_path : NodePath
onready var audio_hit := get_node_or_null(audio_path)
export var pitch_from := 0.7
export var pitch_to := 1.3

func _process(delta):
	velocity = lerp(velocity, (target - angle) * 0.5, delta * weight)
	angle += velocity * 60.0 * delta
	
	if sprites:
		if is_scale:
			sprites.scale = Vector2.ONE + (Vector2.ONE * angle)
		else:
			sprites.rotation_degrees = angle
	
	# cooldown
	cooldown_clock = max(cooldown_clock - delta, 0)

func hit(_scale := 1.0):
	velocity += add_vel * _scale
	
	if is_audio and audio_hit:
		audio_hit.pitch_scale = rand_range(pitch_from, pitch_to)
		audio_hit.play()

func _on_Area2D_area_entered(area):
	if cooldown_clock == 0:
		var gpx = to_local(area.global_position).x
		if abs(gpx) < 1.0: gpx = 1.0 if randf() > 0.5 else -1.0
		hit(-sign(gpx))
		cooldown_clock = cooldown_time
