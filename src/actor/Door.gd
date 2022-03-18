tool
extends Node2D

onready var area : Area2D = $Area2D
onready var arrow := $Arrow
onready var gem := $Gem
onready var audio_open := $Audio/Open

export var dir := 0 setget set_dir
export(String, FILE) var scene_path := ""

export var folder_path := "res://src/map/hub/"
export var scene_name := ""

var is_active := false

var player = null

var arrow_clock := 0.0
var arrow_time := 0.3

var is_complete := false

func _enter_tree():
	if Engine.editor_hint: return
	
	# set path
	if folder_path != "" and scene_name != "":
		scene_path = folder_path + scene_name + ".tscn"
	
	if scene_path != "" and Shared.last_scene == scene_path:
		Shared.door_destination = self

func _ready():
	if Engine.editor_hint: return
	
	var h = "hub" in scene_path
	if h:
		gem.visible = false
	else:
		is_complete = Shared.goals_collected.has(scene_path)
		if is_complete:
			gem.set_color()

func _input(event):
	if Engine.editor_hint: return
	if event.is_action_pressed("up"):
		if is_active and player != null and !player.is_hold and player.dir == dir and player.is_floor:
			enter_door()

func _physics_process(delta):
	if Engine.editor_hint: return
	
	arrow_clock = clamp(arrow_clock + (delta if is_active else -delta), 0, arrow_time)
	arrow.modulate.a = smoothstep(0, 1, arrow_clock / arrow_time)

func set_dir(arg):
	dir = posmod(arg, 4)
	rotation_degrees = dir * 90

func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		if player == null : player = body
		if player.dir == dir:
			is_active = true

func _on_Area2D_body_exited(body):
	is_active = false

func enter_door():
	if scene_path == "": return
	
	# disable player
	player.set_physics_process(false)
	player.anim.play("idle")
	
	# acquire goal
	var gp = get_parent()
	if gp.has_node("Goal"):
		var goal = gp.get_node("Goal")
		if goal != null:
			if goal.is_collected and !Shared.goals_collected.has(Shared.csfn):
				Shared.goals_collected.append(Shared.csfn)
				Shared.is_collect = true
	
	
	audio_open.pitch_scale = rand_range(0.9, 1.1)
	audio_open.play()
	
	if not "hub" in scene_path:
		Shared.is_show_goal = true
	Shared.wipe_scene(scene_path)
