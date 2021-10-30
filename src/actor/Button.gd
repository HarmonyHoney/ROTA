tool
extends Node2D

onready var area : Area2D = $Area2D
onready var anim : AnimationPlayer = $AnimationPlayer

var is_press := false

signal press
signal release

export var is_black := false setget set_black

func set_black(arg):
	is_black = arg
	if is_black:
		$Sprites/Button.modulate = Color(0, 0, 0)
		$Sprites/Floor.visible = false
	else:
		$Sprites/Button.modulate = Color(1, 1, 1)
		$Sprites/Floor.visible = true

func _ready():
	if Engine.editor_hint: return
	
	$Sprites/Button.material = $Sprites/Button.material.duplicate()
	
	for i in get_tree().get_nodes_in_group("switch_block"):
		if i.is_black == is_black:
			connect("press", i, "press")
			connect("release", i, "release")

func _on_Area2D_body_entered(body):
	if !is_press:
		is_press = true
		emit_signal("press")
		anim.play("press")

func _on_Area2D_body_exited(body):
	if is_press and area.get_overlapping_bodies().size() == 0:
		is_press = false
		emit_signal("release")
		anim.play("release")
