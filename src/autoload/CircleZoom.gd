extends CanvasLayer

onready var sprite = $Sprite

var is_zoom := false
var zoom_clock := 0.0
var zoom_time := 1.0

var zoom_from := 0.0
var zoom_to := 0.0

var pos_from := Vector2.ZERO
var pos_to := Vector2.ZERO

signal change_pos(pos)
signal finish

func _ready():
	#sprite.visible = false
	zoom(null, 0.6)

func _physics_process(delta):
	if is_zoom:
		zoom_clock = min(zoom_clock + delta, zoom_time)
		
		var s = smoothstep(0, 1, zoom_clock / zoom_time)
		
		var t = lerp(zoom_from, zoom_to, s)
		set_radius(t)
		
		var p = pos_from.linear_interpolate(pos_to, s)
		set_pos(p)
		
		if zoom_clock == zoom_time:
			is_zoom = false
			emit_signal("finish")
			#sprite.visible = false

func set_radius(rad):
	sprite.material.set_shader_param("radius", rad)

func get_radius():
	return sprite.material.get_shader_param("radius")

func set_pos(p := Vector2.ZERO):
	sprite.material.set_shader_param("start_offset", Vector2(0.5, 0.5) + (p / 1280))
	emit_signal("change_pos", p)

func get_pos():
	return sprite.material.get_shader_param("start_offset")

func zoom(from = null, to = null, time = null, pos = null):
	is_zoom = true
	zoom_clock = 0
	
	zoom_from = from if from != null else get_radius()
	
	if to != null: zoom_to = to
	if time != null: zoom_time = time
	
	pos_from = pos_to
	pos_to = pos if pos != null else Vector2.ZERO
