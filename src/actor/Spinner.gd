tool
extends Node2D

export var is_left := false setget set_left
export var spin_speed : float = 75

onready var sprite : Sprite = $Sprite

func set_left(arg):
	is_left = arg
	$Sprite.flip_h = arg

func _process(delta):
	if Engine.editor_hint: return
	sprite.rotate(deg2rad(spin_speed * delta * -1 if is_left else 1))
	if abs(sprite.rotation_degrees) > 360:
		sprite.rotation_degrees += 360 if is_left else -360

func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		body.spinner(!is_left, position)
	elif body.is_in_group("box"):
		body.spinner(!is_left)
