tool
extends Node2D

onready var area : Area2D = $Area2D
onready var preview := $Preview
onready var sprite : Sprite = $Preview/Sprite

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

func _ready():
	if Engine.editor_hint: return
	
	preview.visible = false
	
	if Shared.map_textures.has(scene_path):
		sprite.texture = Shared.map_textures[scene_path]

func _input(event):
	if Engine.editor_hint: return
	
	if event.is_action_pressed("up"):
		enter_door()

func _physics_process(delta):
	if (is_active and move_clock < move_time) or (!is_active and move_clock > 0):
		move_clock = min(move_clock + delta * (1 if is_active else -1), move_time)
		var s = smoothstep(0, 1, move_clock / move_time)
		preview.position = move_from.linear_interpolate(move_to, s)
		preview.scale = Vector2.ONE * lerp(scale_from, scale_to, s)

func set_dir(arg):
	dir = posmod(arg, 4)
	rotation_degrees = dir * 90

func _on_Area2D_body_entered(body):
	if body is Player:
		if player == null : player = body
		if player.dir == dir:
			is_active = true
			show_preview()

func _on_Area2D_body_exited(body):
	is_active = false
	show_preview()

func show_preview(arg := is_active):
	preview.visible = true

func enter_door():
	if !is_active: return
	if player != null and player.is_hold: return
	
	# acquire goal
	var goal = get_parent().get_node("Goal")
	
	if goal != null:
		if goal.is_collected and !Shared.goals_collected.has(goal.csf):
			Shared.goals_collected.append(goal.csf)
	
	Shared.last_door[get_tree().current_scene.filename] = name
	if scene_path != "":
		Shared.change_scene(scene_path)

