tool
extends Node2D

onready var area : Area2D = $Area2D
onready var door := $Polygon2D
onready var arrow := $Arrow
#onready var arrow_back := $Arrow/Back
onready var csf := get_tree().current_scene.filename
onready var gem := $Gem

export var dir := 0 setget set_dir
export var scene_path := ""

var is_active := false

var move_clock := 0.0
var move_time := 0.5
var move_from = Vector2.ZERO
var move_to = Vector2(0, -250)
var scale_from = 0.0
var scale_to = 1.0

var player = null

export var stage_color := Color("e59d57")
export var hub_color := Color("ff0078")


var arrow_clock := 0.0
var arrow_time := 0.3

var is_complete := false

func _ready():
	if Engine.editor_hint: return
	
	if !Shared.scene_dict.has(csf):
		Shared.scene_dict[csf] = {}
	
	if Shared.scene_dict.has(csf):
		if !Shared.scene_dict[csf].has(name):
			Shared.scene_dict[csf][name] = is_complete
	
	
	
	var h = "hub" in scene_path
	is_complete = Shared.goals_collected.has(scene_path)
	
	if h:
		gem.visible = false
	else:
		if is_complete:
			gem.set_color(true)
	
	
	
	#complete.visible = c and !h
	#incomplete.visible = !c and !h
	#door.color = hub_color if h else stage_color

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
	# disable player
	player.set_physics_process(false)
	player.anim.play("idle")
	
	# acquire goal
	var gp = get_parent()
	if gp.has_node("Goal"):
		var goal = gp.get_node("Goal")
		if goal != null:
			if goal.is_collected and !Shared.goals_collected.has(goal.csf):
				Shared.goals_collected.append(goal.csf)
	
	Shared.last_door[get_tree().current_scene.filename] = name
	if scene_path != "":
		Shared.change_scene(scene_path)
