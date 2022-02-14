extends CanvasLayer

export var col1_a := Color.white
export var col1_b := Color.white
export var col2_a := Color.white
export var col2_b := Color.white

onready var color_rect := $ColorRect

func set_gradient(c1, c2):
	color_rect.material.set_shader_param("col1", c1)
	color_rect.material.set_shader_param("col2", c2)
