extends Node2D

onready var area : Area2D = $Area2D

signal pickup

func _ready():
	for i in get_tree().get_nodes_in_group("game_camera"):
		i.connect("turning", self, "turning")
		break
	for i in get_tree().get_nodes_in_group("lock"):
		connect("pickup", i, "open")

func turning(angle):
	area.rotation = angle

func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		emit_signal("pickup")
		queue_free()
