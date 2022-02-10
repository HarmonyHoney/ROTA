extends Node2D

onready var sprites = $Sprites
onready var anim = $AnimationPlayer

func _ready():
	for i in get_tree().get_nodes_in_group("game_camera"):
		i.connect("turning", self, "turning")
		break

func turning(angle):
	sprites.rotation = angle

func _on_Area2D_body_entered(body):
	visible = false
	pass
