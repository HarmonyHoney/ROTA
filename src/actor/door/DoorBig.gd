tool
extends Door

onready var gem := $Sprites/Gem
onready var label := $Sprites/Gem/Label

export var gem_count := 0 setget set_gem

func _ready():
	set_gem()
	if Engine.editor_hint: return
	
	CheatCode.connect("activate", self, "cheat_code")
	if arrow.is_locked:
		arrow.is_locked = Shared.gem_count < gem_count

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

func on_active():
	UI.up.show = arrow.is_active and gem_count > 0
