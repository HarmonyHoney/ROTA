tool
extends Door

onready var doors := [$Sprites/Left, $Sprites/Right]
onready var labels := [$Sprites/Left/Control/Label, $Sprites/Right/Control/Label]
onready var door_mat : ShaderMaterial = $Sprites/Door.material

export var gem_count := 0 setget set_gem

func _ready():
	set_gem()
	if Engine.editor_hint: return
	
	arrow.connect("activate", self, "activate")
	CheatCode.connect("activate", self, "cheat_code")
	if !arrow.is_locked:
		arrow.is_locked = Shared.gem_count < gem_count

func _physics_process(delta):
	if open_close:
		var s = open_easy.count(delta, open_close > 0)
		door_mat.set_shader_param("line", lerp(0.0, 1.0, s))
		
		for i in doors:
			i.scale.x = lerp(1.0, 0.0, s)
		if open_easy.clock == 0 or open_easy.is_complete:
			open_close = 0

func set_gem(arg := gem_count):
	gem_count = max(arg, 0)
	var v = gem_count > 0
	if labels:
		for i in labels:
			i.text = str(gem_count)
			i.visible = v
	if door_mat:
		door_mat.set_shader_param("gem_size", 0.75 if v else 0.0)

# unlock cheat
func cheat_code(cheat):
	if "konami" in cheat and arrow.is_locked and arrow.is_active:
		unlock()

func unlock():
	arrow.is_locked = false
	arrow.visible = true
	print(name, " unlocked")

func activate():
	UI.up.show = arrow.is_active and gem_count > 0
