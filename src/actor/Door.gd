tool
extends Node2D
class_name Door

export var dir := 0 setget set_dir

export(String, FILE) var scene_path := ""

export var arrow_path : NodePath
export var audio_path : NodePath

onready var arrow := get_node(arrow_path)
onready var audio_open := get_node(audio_path)

var player = null
var is_active := false
export var is_locked := false

var arrow_clock := 0.0
var arrow_time := 0.3

func _enter_tree():
	if Engine.editor_hint: return
	
	# set destination
	if scene_path != "" and Shared.last_scene == scene_path:
		Shared.door_destination = self

func _ready():
	if Engine.editor_hint: return
	player = Shared.player

func _input(event):
	if Engine.editor_hint: return
	if event.is_action_pressed("up"):
		if is_active and !is_locked and player != null and !player.is_hold and player.dir == dir and player.is_floor:
			enter_door()

func _physics_process(delta):
	if Engine.editor_hint: return
	
	# arrow display
	arrow_clock = clamp(arrow_clock + (delta if (is_active and !is_locked) else -delta), 0, arrow_time)
	arrow.modulate.a = smoothstep(0, 1, arrow_clock / arrow_time)

func set_dir(arg):
	dir = posmod(arg, 4)
	rotation_degrees = dir * 90

func _on_Area2D_body_entered(body):
	if body == player and player.dir == dir:
		is_active = true
		on_active()

func _on_Area2D_body_exited(body):
	is_active = false
	on_active()

func enter_door():
	if scene_path != "":
		player.enter_door()
		Shared.wipe_scene(scene_path)
		on_enter()
		
		if audio_open:
			audio_open.pitch_scale = rand_range(0.9, 1.1)
			audio_open.play()

func on_enter():
	pass

func on_active():
	pass

