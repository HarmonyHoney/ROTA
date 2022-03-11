extends CanvasLayer

#onready var color_rect := $ColorRect
onready var mat : ShaderMaterial = $ColorRect.material

export var w1a := Color("0062ff")
export var w1b := Color("00eaff")

export var w2a := Color("af00bf")
export var w2b := Color("0079db")

export var w3a := Color("ff00ff")
export var w3b := Color("009dff")

#export var w4a := Color("7b00ff")
#export var w4b := Color("ff7700")

export var w5a := Color("00eaff")
export var w5b := Color("0062ff")

func _ready():
	set_gradient(w1a, w1b)

func set_gradient(c1, c2):
	mat.set_shader_param("col1", c1)
	mat.set_shader_param("col2", c2)
