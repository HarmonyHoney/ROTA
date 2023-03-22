tool
extends CanvasLayer

var colors = 0
onready var mat : ShaderMaterial = $ColorRect.material
export(Array, Color) var palette setget set_palette
export var clock := 0.0
export var time := 420.0 setget set_time
var frac = 0.0

var step := 0
var step_time := 1.0
var step_frac := 0.0

export var is_editor := false setget set_is_editor

func _ready():
	if Engine.editor_hint: return
	
	randomize()
	clock = randf() * time

func _process(delta):
	if Engine.editor_hint and !is_editor: return
	
	clock = fposmod(clock + delta, time)
	frac = clock / time
	
	step_frac = fposmod(clock, step_time) / step_time
	step = posmod((clock / step_time) + 2, palette.size())
	
	var c1 = palette[step - 2].linear_interpolate(palette[step - 1], step_frac)
	var c2 = palette[step - 1].linear_interpolate(palette[step], step_frac)
	
	if mat:
		mat.set_shader_param("col1", c1)
		mat.set_shader_param("col2", c2)

func set_palette(arg := palette):
	palette = arg
	set_time()

func set_time(arg := time):
	time = abs(arg)
	step_time = time / max(palette.size(), 1.0)
	#print(step_time)

func set_is_editor(arg := is_editor):
	is_editor = arg
	if !is_editor:
		clock = 0.0
		if mat:
			mat.set_shader_param("col1", palette[0])
			mat.set_shader_param("col2", palette[1])

