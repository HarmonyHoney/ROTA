extends Node2D

export var spin_speed : float = 60

onready var sprite : Sprite = $Sprite
onready var modifier : float = 1 if randf() > 0.5 else -1

export var connection_path : NodePath
onready var connection : Node2D = get_node(connection_path)

var ignore

onready var check_area : Area2D = $CheckArea

func _ready():
	if connection.modifier == modifier: connection.modifier = -modifier

func _process(delta):
	sprite.rotate(deg2rad(spin_speed * delta * modifier))

func _on_PortalArea_body_entered(body):
	if body == ignore: return
	for i in connection.check_area.get_overlapping_bodies():
		print(name + " - " + connection.name + " connection blocked")
		return
	
	if body.is_in_group("player"):
		connection.ignore = body
		body.portal(connection.position)
	elif body.is_in_group("box"):
		connection.ignore = body
		body.portal(connection.position)

func _on_PortalArea_body_exited(body):
	if body == ignore:
		ignore = null
