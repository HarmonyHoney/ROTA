tool
extends Node2D
class_name Door

export var dir := 0 setget set_dir

export(String, FILE) var scene_path := ""

onready var arrow := $Arrow
onready var audio_open := $Audio/Open

func _enter_tree():
	if Engine.editor_hint: return
	Shared.doors.append(self)

func _exit_tree():
	if Engine.editor_hint: return
	Shared.doors.erase(self)

func _ready():
	# set is_locked if scene not found
	var f = File.new()
	arrow.is_locked = !f.file_exists(scene_path)
	arrow.connect("open", self, "enter_door")
	arrow.dir = dir

func set_dir(arg):
	dir = posmod(arg, 4)
	rotation_degrees = dir * 90

func enter_door():
	if scene_path != "" and Shared.wipe_scene(scene_path):
		Shared.player.enter_door()
		arrow.is_locked = true
		on_enter()
		
		if audio_open:
			audio_open.pitch_scale = rand_range(0.9, 1.1)
			audio_open.play()
		
		Cam.start_zoom(0, false)

func on_enter():
	pass
