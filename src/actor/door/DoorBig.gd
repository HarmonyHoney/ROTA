tool
extends Door

onready var label := $Sprites/Control/Label
onready var door_mat : ShaderMaterial = $Sprites/Door.material

export var gem_count := 0 setget set_gem

export var is_fade := false setget set_is_fade
var fade_easy := EaseMover.new()
var label_easy := EaseMover.new()
var door_name = ""

func _ready():
	set_gem()
	if Engine.editor_hint: return
	
	arrow.connect("activate", self, "activate")
	CheatCode.connect("activate", self, "cheat_code")
	if !arrow.is_locked:
		arrow.is_locked = Shared.gem_count < gem_count
	
	door_name = Shared.map_name + ":" + name
	
	is_cutscene = gem_count > 0 and !Shared.doors_unlocked.has(door_name)
	if door_mat:
		for i in 2:
			door_mat.set_shader_param(["gem_col", "gem_fill"][i] , colors[(0 if is_cutscene else 2) + i])
	
	label.modulate.a = 0.0

func _physics_process(delta):
	if Engine.editor_hint: return
	
	if open_close:
		var s = open_easy.count(delta, open_close > 0)
		door_mat.set_shader_param("line", lerp(0.0, 1.0, s))
		
		if open_easy.clock == 0 or open_easy.is_complete:
			open_close = 0
	
	if is_instance_valid(arrow):
		var l = label_easy.count(delta, arrow.is_active and is_cutscene)
		if !label_easy.is_last:
			label.modulate.a = l
	
	if is_fade:
		var f = fade_easy.count(delta)
		is_fade = !fade_easy.is_complete
		if door_mat:
			for i in 2:
				door_mat.set_shader_param(["gem_col", "gem_fill"][i], colors[i].linear_interpolate(colors[2 + i], f))

func set_gem(arg := gem_count):
	gem_count = max(arg, 0)
	var v = gem_count > 0
	if is_instance_valid(label):
		label.text = str(gem_count)
		label.visible = v
	
	if door_mat:
		door_mat.set_shader_param("gem_size", 0.75 if v else 0.0)

func set_is_fade(arg := is_fade):
	is_fade = arg
	fade_easy.clock = 0.0 if is_fade else fade_easy.time

# unlock cheat
func cheat_code(cheat):
	if "konami" in cheat and arrow.is_locked and arrow.is_active:
		arrow.is_locked = false
		print(name, " unlocked")

func activate():
	UI.up.show = arrow.is_active and is_cutscene

func on_enter():
	if !Shared.doors_unlocked.has(door_name):
		Shared.doors_unlocked.append(door_name)
