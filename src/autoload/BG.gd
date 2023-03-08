tool
extends CanvasLayer

onready var mat : ShaderMaterial = $ColorRect.material
export var colors = 0 setget set_colors
export(PoolColorArray) var palette : PoolColorArray = ["0062ff", "00eaff", "af00bf", "0079db", "ff00ff", "009dff", "00eaff", "0062ff", "6666ff", "00004d"]

func _ready():
	self.colors = 0

func set_colors(arg := 0):
	colors =  posmod(arg, palette.size() / 2)
	#print("BG: ", colors, " pal: ", palette.size(), " / 2 = ", palette.size() / 2)
	if mat:
		mat.set_shader_param("col1", palette[colors * 2])
		mat.set_shader_param("col2", palette[(colors * 2) + 1])
