tool
extends Node2D

onready var area : Area2D = $Area2D
onready var preview := $Preview
onready var sprite : Sprite = $Preview/Sprite
onready var door := $Polygon2D
onready var arrow := $Arrow
#onready var arrow_back := $Arrow/Back

export var dir := 0 setget set_dir
export var scene_path := ""

var is_active := false

onready var preview_pos : Vector2 = preview.position

var move_clock := 0.0
var move_time := 0.5
var move_from = Vector2.ZERO
var move_to = Vector2(0, -250)
var scale_from = 0.0
var scale_to = 1.0

var player = null

export var stage_color := Color("e59d57")
export var hub_color := Color("ff0078")

onready var complete := $Complete
onready var incomplete := $Incomplete


#var open_clock := 0.0
#var open_time := 0.5

func _ready():
	if Engine.editor_hint: return
	
	preview.visible = false
	
	if Shared.map_textures.has(scene_path):
		sprite.texture = Shared.map_textures[scene_path]
	
	var h = "hub" in scene_path
	var c = Shared.goals_collected.has(scene_path)
		
	complete.visible = c and !h
	incomplete.visible = !c and !h
	door.color = hub_color if h else stage_color
	
	arrow.visible = is_active
	#set_progress(0)

func _input(event):
	if event.is_action_pressed("up"):
		if is_active and player != null and !player.is_hold and player.dir == dir and player.is_floor:
			enter_door()

#func _physics_process(delta):
#	if is_active:
#		var is_up = Input.is_action_pressed("up") and player != null and !player.is_hold
#
#		open_clock = clamp(open_clock + (delta if is_up else -delta), 0, open_time)
#		set_progress()
#
#		if open_clock == open_time:
#			enter_door()


func set_dir(arg):
	dir = posmod(arg, 4)
	rotation_degrees = dir * 90

func _on_Area2D_body_entered(body):
	if body is Player:
		if player == null : player = body
		if player.dir == dir:
			is_active = true
			arrow.visible = is_active
#			open_clock = 0.0
#			set_progress()

func _on_Area2D_body_exited(body):
	is_active = false
	arrow.visible = is_active
#	open_clock = 0.0
#	set_progress()

#func show_preview(arg := is_active):
#	preview.visible = true

func enter_door():
	# disable player
	player.set_physics_process(false)
	player.anim.play("idle")
	
	# acquire goal
	var goal = get_parent().get_node("Goal")
	
	if goal != null:
		if goal.is_collected and !Shared.goals_collected.has(goal.csf):
			Shared.goals_collected.append(goal.csf)
	
	Shared.last_door[get_tree().current_scene.filename] = name
	if scene_path != "":
		Shared.change_scene(scene_path)

#func set_progress(arg = open_clock / open_time):
#	var s = smoothstep(0, 1, open_clock / open_time)
#	arrow_back.material.set_shader_param("progress", 1 - s)
