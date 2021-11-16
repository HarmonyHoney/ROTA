extends Node2D

onready var sprites = $Sprites
onready var anim = $AnimationPlayer

func _ready():
	for i in get_tree().get_nodes_in_group("game_camera"):
		i.connect("set_rotation", self, "set_rotation")
		break

func set_rotation(degrees):
	sprites.rotation_degrees = degrees

func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		body.win()
		anim.play("open")
		print("map complete")
