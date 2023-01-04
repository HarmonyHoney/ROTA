tool
extends Door

onready var gem := $Sprites/Gem
onready var label := $Sprites/Gem/Label
onready var door_mat : ShaderMaterial = $Sprites/Door.material
onready var knobs = [$Sprites/Knob, $Sprites/Knob2]

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
		gem.modulate.a = 1.0 - s
		for i in knobs:
			i.scale.x = lerp(1.0, 0.0, s)
		if open_easy.clock == 0 or open_easy.is_complete:
			open_close = 0

func set_gem(arg := gem_count):
	gem_count = max(arg, 0)
	if label:
		label.text = str(gem_count)
	if gem:
		gem.visible = gem_count > 0

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
