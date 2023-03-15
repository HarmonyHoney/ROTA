tool
extends CanvasLayer

onready var mat : ShaderMaterial = $ColorRect.material
export var colors = 0 setget set_colors
export(Array, PoolColorArray) var palettes setget set_palettes

export var clock := 0.0
export var time := 600.0 setget set_time
var frac = 0.0

var step := 0
var step_colors : Array
var step_clock := 0.0
var step_time := 1.0
var step_frac := 0.0

func _ready():
	if Engine.editor_hint: return
	
	set_colors()
	
	randomize()
	if randf() > 0.5:
		clock = time / 2.0

func _process(delta):
	if Engine.editor_hint: return
	
	clock = fposmod(clock + delta, time)
	frac = clock / time
	
	step_frac = fposmod(clock, step_time) / step_time
	step = posmod((clock / step_time) + 2, step_colors.size())
	
	var c1 = step_colors[step - 2].linear_interpolate(step_colors[step - 1], step_frac)
	var c2 = step_colors[step - 1].linear_interpolate(step_colors[step], step_frac)
	
	if mat:
		mat.set_shader_param("col1", c1)
		mat.set_shader_param("col2", c2)


func set_time(arg := time):
	time = abs(arg)
	step_time = time / max(step_colors.size(), 1.0)
	#print(step_time)

func set_colors(arg := colors):
	if palettes.size() > 0:
		colors = posmod(arg, palettes.size())
		step_colors = palettes[colors]
		set_time()
		if mat:
			mat.set_shader_param("col1", step_colors[0])
			mat.set_shader_param("col2", step_colors[1])

func set_palettes(arg := palettes):
	palettes = arg
	set_colors()
	#print("palettes: ", palettes)

