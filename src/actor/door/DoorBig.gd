tool
extends Door

onready var label := $Sprites/Control/Label
onready var door_mat : ShaderMaterial = $Sprites/Door.material

export var gem_count := 0 setget set_gem

export var is_fade := false setget set_is_fade
var fade_easy := EaseMover.new()
var label_easy := EaseMover.new()
var ring_clock := 0.0

func _ready():
	set_gem()
	if Engine.editor_hint: return
	
	arrow.connect("activate", self, "activate")
	CheatCode.connect("activate", self, "cheat_code")
	if !arrow.is_locked: arrow.is_locked = Shared.gem_count < gem_count
	
	is_cutscene = gem_count > 0 and (arrow.is_locked or !Shared.maps_visited.has(map_path))
	gem_color(!is_cutscene)
	
	label.modulate.a = 0.0
		
	door_mat.set_shader_param("line", 0.0)

func _physics_process(delta):
	if Engine.editor_hint: return
	
	if open_close:
		var s = open_count(delta)
		door_mat.set_shader_param("line", lerp(0.0, 1.0, s))
	
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
		Audio.play("gem_show", 0.5)
		print(name, " unlocked")

func activate():
	UI.up.show = arrow.is_active and is_cutscene

func on_enter():
	door_mat.set_shader_param("ring_offset", -door_mat.get_shader_param("ring_offset"))

func gem_color(is_gold := false):
	if door_mat:
		for i in 2:
			door_mat.set_shader_param(["gem_col", "gem_fill"][i] , colors[(2 if is_gold else 0) + i])
		
