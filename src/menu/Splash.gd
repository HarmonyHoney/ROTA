extends Node

func _ready():
	await get_tree().idle_frame
	$AudioStreamPlayer.play()
	await get_tree().create_timer(1.25).timeout
	Shared.wipe_scene(Shared.title_path)
