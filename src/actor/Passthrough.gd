extends Node2D

onready var dotted : Sprite = $Sprites/Dotted
onready var rect : Sprite = $Sprites/Rect
onready var static_body : StaticBody2D = $StaticBody2D
onready var area : Area2D = $Area2D

var is_solid := false

var solid_clock := 0.1

func _ready():
	set_physics_process(false)

func _on_Area2D_body_exited(body):
	if !is_physics_processing() and (body.is_in_group("player") or body.is_in_group("box")):
		set_physics_process(true)

func _physics_process(delta):
	solid_clock = max(0, solid_clock - delta)
	if solid_clock == 0 and area.get_overlapping_bodies().size() == 0:
		make_solid()
		set_physics_process(false)

func make_solid():
	is_solid = true
	print(name, " became solid")
	dotted.visible = false
	rect.visible = true
	static_body.set_collision_layer_bit(0, true)
