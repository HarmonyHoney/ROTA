extends Node2D

var shader_scale = 100.0

func _ready():
	get_tree().get_root().connect("size_changed", self, "size_changed")


func size_changed():
	$Sprite.material.set_shader_param("scale", (get_viewport().size.x/ 1280) * shader_scale)
	print(get_viewport_rect())
