tool
extends Node2D

onready var area : Area2D = $Area2D
onready var arrow := $Arrow
onready var gems := $Gems

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

export var col_1a := Color("ffdd00")
export var col_1b := Color("fffb00")

export var col_2a := Color("af00ff")
export var col_2b := Color("ff00e9")

export var is_gem := false
export var gem_count := 1
export var gem_radius := 60.0
export var gem_world := ""

var gems_collected := 0
var is_locked := false

var arrow_clock = 0.0
var arrow_time = 0.3

func _ready():
	if Engine.editor_hint: return
	
	gems.visible = is_gem
	if is_gem:
		
		if gem_world != "":
			for i in Shared.goals_collected:
				if i.begins_with(gem_world):
					gems_collected += 1
		
		for i in gem_count:
			var gem = $Gems/Gem.duplicate()
			gems.add_child(gem)
			gem.owner = self
			var angle = (float(i) / float(gem_count)) * TAU
			gem.position = Vector2(0, gem_radius).rotated(angle)
			gem.rotation = angle
			
			if i >= gems_collected:
				gem.color = col_2a
				gem.get_child(0).color = col_2b
		$Gems/Gem.queue_free()
		
		is_locked = gems_collected < gem_count
		

func _input(event):
	if Engine.editor_hint: return
	
	if is_active:
		if event.is_action_pressed("up"):
			enter_door()
		
		# dev cheat unlock
		if is_locked and Input.is_action_pressed("jump") and Input.is_action_pressed("push"):
			is_locked = false
			arrow.visible = true

func _physics_process(delta):
	if Engine.editor_hint: return
	
	arrow_clock = clamp(arrow_clock + (delta if (is_active and !is_locked) else -delta), 0, arrow_time)
	arrow.modulate.a = smoothstep(0, 1, arrow_clock / arrow_time)

func set_dir(arg):
	dir = posmod(arg, 4)
	rotation_degrees = dir * 90

func _on_Area2D_body_entered(body):
	if body is Player:
		if player == null : player = body
		if player.dir == dir:
			is_active = true

func _on_Area2D_body_exited(body):
	is_active = false

func enter_door():
	if!is_locked and player != null and !player.is_hold and player.is_floor:
		Shared.last_door[get_tree().current_scene.filename] = name
		if scene_path != "":
			Shared.change_scene(scene_path)

