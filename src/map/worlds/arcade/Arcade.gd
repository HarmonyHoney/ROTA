extends Node2D

onready var player = Shared.player

func _ready():
	player.is_input = false
	Cam.target_node = null
	Cam.target_pos = Vector2(1280, 720) * 0.5
	
func _exit_tree():
	player.is_input = true
	Cam.target_node = player
