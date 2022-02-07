extends CanvasLayer

onready var circle = $ColorRect

var is_zoom := false
var zoom_clock := 0.0
var zoom_time := 1.0

var zoom_from := 0.0
var zoom_to := 0.0

var pos_from := Vector2.ZERO
var pos_to := Vector2.ZERO

var out := 0.585

signal change_pos(pos)
signal finish

var pos = Vector2.ZERO
var radius = 0.0


func _ready():
	#circle.visible = false
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
			#circle.visible = false

func set_radius(rad):
	circle.material.set_shader_param("radius", rad)
	radius = rad

#func get_radius():
#	return circle.material.get_shader_param("radius")

func set_pos(p := Vector2.ZERO):
	circle.material.set_shader_param("start_offset", Vector2(0.5, 0.5) + (p / 1280))
	pos = p
	emit_signal("change_pos", p)

func get_pos():
	return circle.material.get_shader_param("start_offset")

func zoom(from = null, to = null, time = null, p_from = null, p_to = null):
	is_zoom = true
	zoom_clock = 0
	
	zoom_from = from if from != null else radius
	zoom_to = to if to != null else out
	zoom_time = time if time != null else 0.5
	
	pos_from = p_from if p_from != null else pos
	pos_to = p_to if p_to != null else Vector2.ZERO
