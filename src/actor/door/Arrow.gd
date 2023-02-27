tool
extends Node2D
class_name Arrow

export var dir := 0
export var col_size := Vector2(40, 50) setget set_col_size
export var col_pos := Vector2(0, 0) setget set_col_pos
export var image_pos := Vector2(0, -95) setget set_image_pos

onready var image := $Image
onready var mat : ShaderMaterial = $Image/Rect.material
onready var area := $Area2D
onready var col_shape := $Area2D/CollisionShape2D

var player = null
var body = null
var is_active := false
var is_locked := false

var arrow_clock := 0.0
var arrow_time := 0.3

var open_clock := 0.0
var open_time := 0.5
var open_last := 0.0

var start_clock := 0.0
var start_time := 0.5

signal activate
signal open

func _ready():
	set_col_size()
	set_col_pos()
	set_image_pos()
	
	if Engine.editor_hint: return
	
	player = Shared.player
	image.modulate.a = 0.0
	mat.set_shader_param("fill_y", 0.0)

func _physics_process(delta):
	if Engine.editor_hint: return
	
	# starting delay
	if Cutscene.is_playing or start_clock < start_time:
		start_clock += delta
		return
	
	# image display
	arrow_clock = clamp(arrow_clock + (delta if (is_active and !is_locked) else -delta), 0, arrow_time)
	image.modulate.a = smoothstep(0, 1, arrow_clock / arrow_time)
	
	# activate
	try_active()
	
	# open door
	open_last = open_clock
	var open = Input.is_action_pressed("up") and is_active and !is_locked and player != null and !player.is_hold and player.dir == dir and player.is_floor
	open_clock = clamp(open_clock + (delta if open else -delta), 0, open_time)
	
	if open_clock > 0:
		var os = smoothstep(0, 1, open_clock / open_time)
		mat.set_shader_param("fill_y", os)
		
		if open_clock == open_time and open_last != open_time:
			emit_signal("open")

func set_col_size(arg := col_size):
	col_size = arg
	if col_shape: col_shape.shape.extents = col_size

func set_col_pos(arg := col_pos):
	col_pos = arg
	if area: area.position = col_pos

func set_image_pos(arg := image_pos):
	image_pos = arg
	if image: image.position = image_pos

func _on_Area2D_body_entered(_body):
	body = _body
	try_active()

func _on_Area2D_body_exited(_body):
	body = null
	try_active()

func try_active():
	if (is_active and (body != player or (player.dir != dir))) or (!is_active and body == player and player.dir == dir):
		is_active = !is_active
		emit_signal("activate")

func turn(arg):
	dir = posmod(arg, 4)
