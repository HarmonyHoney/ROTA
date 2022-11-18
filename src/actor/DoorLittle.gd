tool
extends Door

onready var gem := $Gem
onready var clock := $Clock

func _ready():
	if Engine.editor_hint: return
	
	var m = scene_path.lstrip(Shared.worlds_path).rstrip(".tscn")
	clock.visible = Shared.goals.has(m) and Shared.goals[m] > 0 and Shared.speedruns.has(m) and Shared.goals[m] < Shared.speedruns[m]
	gem.visible = !clock.visible
	
	if "hub" in scene_path:
		gem.visible = false
	elif Shared.goals.has(m):
		gem.set_color()
	
	try_path()

# acquire goal
func on_enter():
	Shared.collect_gem()
