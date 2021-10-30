tool
extends Node2D

onready var dotted : Sprite = $Sprites/Dotted
onready var rect : Sprite = $Sprites/Rect
onready var area : Area2D = $Area2D
onready var static_body : StaticBody2D = $StaticBody2D

var is_solid := false
var is_queue := false

export var is_black := false setget set_black

func set_black(arg):
	is_black = arg
	$Sprites/Fill.modulate = Color(0, 0, 0) if is_black else Color(1, 1, 1)

func press():
	if area.get_overlapping_bodies().size() == 0:
		make_solid()
	else:
		is_queue = true

func _on_Area2D_body_exited(body):
	if is_queue and area.get_overlapping_bodies().size() == 0:
		make_solid()

func make_solid():
	is_solid = true
	is_queue = false
	static_body.set_collision_layer_bit(0, true)
	dotted.visible = false
	rect.visible = true

func release():
	is_solid = false
	is_queue = false
	static_body.set_collision_layer_bit(0, false)
	dotted.visible = true
	rect.visible = false



