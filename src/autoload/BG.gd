tool
extends CanvasLayer

onready var mat : ShaderMaterial = $ColorRect.material
export var colors = 0 setget set_colors
export(PoolColorArray) var palette : PoolColorArray = ["0062ff", "00eaff", "af00bf", "0079db", "ff00ff", "009dff", "00eaff", "0062ff", "6666ff", "00004d"]

onready var center := $Center
onready var sun := $Center/Sun
export var rot_speed := 100.0


func _ready():
	self.colors = 0

func _physics_process(delta):
	if Engine.editor_hint: return
	
	if center: center.rotate(deg2rad(rot_speed * delta))

func set_colors(arg := 0):
	colors = clamp(arg, 0, (palette.size() / 2) - 1)
	#print("BG: ", colors, " pal: ", palette.size(), " / 2 = ", palette.size() / 2)
	if mat:
		mat.set_shader_param("col1", palette[colors * 2])
		mat.set_shader_param("col2", palette[(colors * 2) + 1])
