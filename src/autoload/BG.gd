extends CanvasLayer

onready var color_rect := $ColorRect

export var w1a := Color("0062ff")
export var w1b := Color("00eaff")

export var w2a := Color("c900db")
export var w2b := Color("0079db")

export var w3a := Color("c900db")
export var w3b := Color("0079db")

func _ready():
	set_gradient(w1a, w1b)

func set_gradient(c1, c2):
	color_rect.material.set_shader_param("col1", c1)
	color_rect.material.set_shader_param("col2", c2)
