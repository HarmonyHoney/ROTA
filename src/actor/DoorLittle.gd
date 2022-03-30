tool
extends Door

onready var gem := $Gem

func _ready():
	if Engine.editor_hint: return
	
	if "hub" in scene_path:
		gem.visible = false
	elif Shared.goals_collected.has(scene_path):
		gem.set_color()

# acquire goal
func on_enter():
	Shared.collect_gem()
