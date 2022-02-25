extends CanvasLayer

export var w1a := Color("0062ff")
export var w1b := Color("00eaff")

export var w2a := Color("c900db")
export var w2b := Color("0079db")

onready var color_rect := $ColorRect

func set_gradient(c1, c2):
	color_rect.material.set_shader_param("col1", c1)
	color_rect.material.set_shader_param("col2", c2)
