tool
extends CanvasLayer

onready var mat : ShaderMaterial = $ColorRect.material
export var colors = 0 setget set_colors
export(Array, PoolColorArray) var palettes
var step_colors : Array

var clock := 0.0
export var daytime := 60.0
var time := 10.0
var frac = 0.0

func _ready():
	if Engine.editor_hint: return
	
	self.colors = 0

func _process(delta):
	if Engine.editor_hint: return
	
	clock += delta
	if clock > time:
		clock = fposmod(clock, time)
		step_colors.append(step_colors.pop_front())
		
	frac = clock / time
	
	var c1 = step_colors[0].linear_interpolate(step_colors[1], frac)
	var c2 = step_colors[1].linear_interpolate(step_colors[2], frac)
	
	if mat:
		mat.set_shader_param("col1", c1)
		mat.set_shader_param("col2", c2)
	

func set_colors(arg := 0):
	if palettes.size() > 0:
		colors = posmod(arg, palettes.size())
		step_colors = palettes[colors]
		time =  daytime / max(step_colors.size(), 1.0)
		print(time)
		if mat:
			mat.set_shader_param("col1", step_colors[0])
			mat.set_shader_param("col2", step_colors[1])
