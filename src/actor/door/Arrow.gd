tool
extends Node2D
class_name Arrow

export var dir := 0 setget set_dir
export var is_turn := false
export var col_show := false setget set_col_show
export var col_size := Vector2(40, 50) setget set_col_size
export var col_pos := Vector2(0, 0) setget set_col_pos
export var image_show := false setget set_image_show
export var image_pos := Vector2(0, -95) setget set_image_pos

onready var image := $Image
onready var area := $Area2D
onready var col_shape := $Area2D/CollisionShape2D

var player = null
var body = null
var is_active := false
var is_locked := false

var arrow_easy := EaseMover.new(0.3)
var open_easy := EaseMover.new()

var start_clock := 0.0
var start_time := 0.5

signal activate
signal open

func _ready():
	set_col_show()
	set_col_size()
	set_col_pos()
	set_image_pos()
	
	if Engine.editor_hint: return
	self.image_show = false
	
	player = Shared.player

func _physics_process(delta):
	if Engine.editor_hint: return
	
	# starting delay
	if Cutscene.is_playing or start_clock < start_time:
		start_clock += delta
		return
	
	# image display
	arrow_easy.count(delta, is_active and !is_locked)
	
	# activate
	try_active()
	
	# open door
	var open = Input.is_action_pressed("up") and is_active and !is_locked and player != null and !player.is_hold and player.dir == dir and player.is_floor
	open_easy.count(delta, open)
	
	if open_easy.clock > 0:
		if open_easy.is_complete and !open_easy.is_last:
			emit_signal("open")

func set_dir(arg := dir):
	dir = posmod(arg, 4)
	if is_turn: rotation_degrees = 90 * dir

func set_col_show(arg := col_show):
	col_show = arg
	if col_shape: col_shape.visible = col_show

func set_col_size(arg := col_size):
	col_size = arg
	if col_shape: col_shape.shape.extents = col_size

func set_col_pos(arg := col_pos):
	col_pos = arg
	if area: area.position = col_pos

func set_image_show(arg := image_show):
	image_show = arg
	if image: image.visible = image_show

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
		if is_active and Shared.arrow_track != self:
			Shared.arrow_track = self
			Shared.arrow.global_transform = image.global_transform
