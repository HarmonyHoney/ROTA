tool
extends Node2D
class_name Door

export var dir := 0 setget set_dir
export(String, FILE) var scene_path := ""
export var audio_range := Vector2(0.85, 1.15)

var open_easy := EaseMover.new()
var is_open := false
var is_close := false
var open_close := 0

onready var arrow := $Arrow

func _enter_tree():
	if Engine.editor_hint: return
	Shared.doors.append(self)
	Shared.connect("scene_changed", self, "scene_changed")

func _exit_tree():
	if Engine.editor_hint: return
	Shared.doors.erase(self)

func _ready():
	# set is_locked if scene not found
	var f = File.new()
	arrow.is_locked = !f.file_exists(scene_path)
	arrow.connect("open", self, "enter_door")
	arrow.dir = dir

func scene_changed():
	if Shared.door_in == self:
		open_close = -1
		open_easy.clock = open_easy.time

func set_dir(arg):
	dir = posmod(arg, 4)
	rotation_degrees = dir * 90

func enter_door():
	if scene_path != "" and Shared.wipe_scene(scene_path, Shared.csfn, 0.5):
		Shared.player.enter_door()
		arrow.is_locked = true
		open_close = 1
		open_easy.clock = 0.0
		on_enter()
		
		Audio.play("door_open", audio_range.x, audio_range.y)
		Cam.start_zoom(0, false)

func on_enter():
	pass
