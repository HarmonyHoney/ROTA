extends CanvasLayer

onready var mat : ShaderMaterial = $ColorRect.material
export(PoolColorArray) var test : PoolColorArray = ["0062ff", "00eaff", "af00bf", "0079db", "ff00ff", "009dff", "00eaff", "0062ff"]

func _ready():
	set_colors(0)

func set_colors(arg := 0):
	if (arg * 2) + 1 < test.size():
		mat.set_shader_param("col1", test[arg * 2])
		mat.set_shader_param("col2", test[(arg * 2) + 1])
