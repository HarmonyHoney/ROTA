extends CanvasLayer

export var colors = 0 setget set_colors
onready var mat : ShaderMaterial = $ColorRect.material
export(PoolColorArray) var test : PoolColorArray = ["0062ff", "00eaff", "af00bf", "0079db", "ff00ff", "009dff", "00eaff", "0062ff"]

func _ready():
	self.colors = 0

func set_colors(arg := 0):
	colors = abs(arg)
	if mat and (colors * 2) + 1 < test.size():
		mat.set_shader_param("col1", test[colors * 2])
		mat.set_shader_param("col2", test[(colors * 2) + 1])
